DATASET_DIR=/content/drive/MyDrive/color_image_sample_jpg

mkdir -p ./checkpoints/siggraph_retrained
MODEL_FILE=./checkpoints/siggraph_retrained/latest_net_G.pth
URL=http://colorization.eecs.berkeley.edu/siggraph/models/pytorch.pth
wget -N $URL -O $MODEL_FILE

# Stage 1: Training Full Image Colorization
mkdir ./checkpoints/coco_full
cp ./checkpoints/siggraph_retrained/latest_net_G.pth ./checkpoints/coco_full/
python train.py --stage full --name coco_full --sample_p 1.0 --niter 100 --niter_decay 50 --load_model --lr 0.0005 --model train --fineSize 256 --batch_size 16 --display_ncols 3 --display_freq 1600 --print_freq 1600 --train_img_dir $DATASET_DIR

# Stage 2: Training Instance Image Colorization
mkdir ./checkpoints/coco_instance
cp ./checkpoints/coco_full/latest_net_G.pth ./checkpoints/coco_instance/
python train.py --stage instance --name coco_instance --sample_p 1.0 --niter 100 --niter_decay 50 --load_model --lr 0.0005 --model train --fineSize 256 --batch_size 16 --display_ncols 3 --display_freq 1600 --print_freq 1600 --train_img_dir $DATASET_DIR

# Stage 3: Training Fusion Module
mkdir ./checkpoints/coco_mask
cp ./checkpoints/coco_full/latest_net_G.pth ./checkpoints/coco_mask/latest_net_GF.pth
cp ./checkpoints/coco_instance/latest_net_G.pth ./checkpoints/coco_mask/latest_net_G.pth
cp ./checkpoints/coco_full/latest_net_G.pth ./checkpoints/coco_mask/latest_net_GComp.pth
python train.py --stage fusion --name coco_mask --sample_p 1.0 --niter 10 --niter_decay 20 --lr 0.00005 --model train --load_model --display_ncols 4 --fineSize 256 --batch_size 1 --display_freq 500 --print_freq 500 --train_img_dir $DATASET_DIR