## **Installation**
1. Open Git Bash on your Windows 11 system.
2. Create and activate a new conda environment (replace `janus-env` with your preferred name):
   ```bash
   conda create -n janus-env python=3.8
   conda activate janus-env
   ```
3. Install the required dependencies:
   ```bash
   conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
   conda install -c conda-forge git
   pip install transformers
   pip install -e .
   ```
4. Clone the Janus repository:
   ```bash
   git clone https://github.com/deepseek-ai/Janus.git
   cd Janus
   pip install -e .
   ```

---

## **Environment Setup**
1. Ensure you have an NVIDIA GPU with CUDA installed. If not, download the CUDA toolkit from [NVIDIA’s website](https://developer.nvidia.com/cuda-downloads).
2. Verify CUDA installation by running:
   ```bash
   nvidia-smi
   ```
3. If using Windsurf IDE, ensure your project is set up with the correct Python interpreter (Python 3.8 or higher).

---

## **Multimodal Understanding (Image Description)**
1. Open a Python file in your preferred IDE (e.g., Windsurf IDE).
2. Import the necessary libraries and load the model:
   ```python
   import torch
   from transformers import AutoModelForCausalLM
   from janus.models import MultiModalityCausalLM, VLChatProcessor
   from janus.utils.io import load_pil_images

   model_path = "deepseek-ai/Janus-Pro-7B"
   vl_chat_processor = VLChatProcessor.from_pretrained(model_path)
   tokenizer = vl_chat_processor.tokenizer

   vl_gpt = AutoModelForCausalLM.from_pretrained(
       model_path, trust_remote_code=True
   )
   vl_gpt = vl_gpt.to(torch.bfloat16).cuda().eval()
   ```

3. Prepare your conversation and image:
   ```python
   conversation = [
       {
           "role": "<|User|>",
           "content": f"<image_placeholder>\n{question}",
           "images": [image],
       },
       {"role": "<|Assistant|>", "content": ""},
   ]
   ```

4. Load and process the image:
   ```python
   pil_images = load_pil_images(conversation)
   prepare_inputs = vl_chat_processor(
       conversations=conversation, images=pil_images, force_batchify=True
   ).to(vl_gpt.device)
   ```

5. Run the model to generate a response:
   ```python
   inputs_embeds = vl_gpt.prepare_inputs_embeds(**prepare_inputs)
   outputs = vl_gpt.language_model.generate(
       inputs_embeds=inputs_embeds,
       attention_mask=prepare_inputs.attention_mask,
       pad_token_id=tokenizer.eos_token_id,
       bos_token_id=tokenizer.bos_token_id,
       eos_token_id=tokenizer.eos_token_id,
       max_new_tokens=512,
       do_sample=False,
       use_cache=True,
   )
   answer = tokenizer.decode(outputs[0].cpu().tolist(), skip_special_tokens=True)
   print(f"{prepare_inputs['sft_format'][0]}", answer)
   ```

---

## **Text-to-Image Generation**
1. Import the necessary libraries and load the model (same as above).
2. Define your text prompt:
   ```python
   conversation = [
       {
           "role": "<|User|>",
           "content": "A stunning princess from kabul in red, white traditional clothing, blue eyes, brown hair",
       },
       {"role": "<|Assistant|>", "content": ""},
   ]
   ```

3. Prepare the prompt and generate the image:
   ```python
   sft_format = vl_chat_processor.apply_sft_template_for_multi_turn_prompts(
       conversations=conversation,
       sft_format=vl_chat_processor.sft_format,
       system_prompt="",
   )
   prompt = sft_format + vl_chat_processor.image_start_tag
   ```

4. Run the generation function:
   ```python
   @torch.inference_mode()
   def generate(
       mmgpt: MultiModalityCausalLM,
       vl_chat_processor: VLChatProcessor,
       prompt: str,
       temperature: float = 1,
       parallel_size: int = 16,
       cfg_weight: float = 5,
       image_token_num_per_image: int = 576,
       img_size: int = 384,
       patch_size: int = 16,
   ):
       input_ids = vl_chat_processor.tokenizer.encode(prompt)
       input_ids = torch.LongTensor(input_ids)

       tokens = torch.zeros((parallel_size*2, len(input_ids)), dtype=torch.int).cuda()
       for i in range(parallel_size*2):
           tokens[i, :] = input_ids
           if i % 2 != 0:
               tokens[i, 1:-1] = vl_chat_processor.pad_id

       inputs_embeds = mmgpt.language_model.get_input_embeddings()(tokens)

       generated_tokens = torch.zeros((parallel_size, image_token_num_per_image), dtype=torch.int).cuda()

       for i in range(image_token_num_per_image):
           outputs = mmgpt.language_model.model(inputs_embeds=inputs_embeds, use_cache=True, past_key_values=outputs.past_key_values if i != 0 else None)
           hidden_states = outputs.last_hidden_state
            
           logits = mmgpt.gen_head(hidden_states[:, -1, :])
           logit_cond = logits[0::2, :]
           logit_uncond = logits[1::2, :]
           
           logits = logit_uncond + cfg_weight * (logit_cond-logit_uncond)
           probs = torch.softmax(logits / temperature, dim=-1)

           next_token = torch.multinomial(probs, num_samples=1)
           generated_tokens[:, i] = next_token.squeeze(dim=-1)

           next_token = torch.cat([next_token.unsqueeze(dim=1), next_token.unsqueeze(dim=1)], dim=1).view(-1)
           img_embeds = mmgpt.prepare_gen_img_embeds(next_token)
           inputs_embeds = img_embeds.unsqueeze(dim=1)


   dec = mmgpt.gen_vision_model.decode_code(generated_tokens.to(dtype=torch.int), shape=[parallel_size, 8, img_size//patch_size, img_size//patch_size])
   dec = dec.to(torch.float32).cpu().numpy().transpose(0, 2, 3, 1)

   dec = np.clip((dec + 1) / 2 * 255, 0, 255)

   visual_img = np.zeros((parallel_size, img_size, img_size, 3), dtype=np.uint8)
   visual_img[:, :, :] = dec

   os.makedirs('generated_samples', exist_ok=True)
   for i in range(parallel_size):
       save_path = os.path.join('generated_samples', "img_{}.jpg".format(i))
       PIL.Image.fromarray(visual_img[i]).save(save_path)

   generate(
       vl_gpt,
       vl_chat_processor,
       prompt,
   )
   ```

---

## **Troubleshooting**
- Ensure CUDA is properly installed and recognized by running `nvidia-smi`.
- Verify that the model is downloaded correctly by checking the `model_path`.
- If you encounter missing dependencies, install them using `pip install -r requirements.txt`.

Let me know if you need further clarification!