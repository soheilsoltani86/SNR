clear all
close all
clc
% fold='C:\EI institute Folders\TPE-imaging optimization\New Folder';
fold=pwd;
figures_folder='C:\EI institute Folders\TPE-imaging optimization\Signal_Noise analysis-YM\saved images';
filepattern = fullfile(fold, '*.tif');
imgfiles = dir(filepattern);
name=[];
SNR_m=[];%%
options=[];

for k = 1:2:size(imgfiles)
    
img=double(imread(imgfiles(k).name));

figure(1)
imagesc(img); colormap gray
% temp_str = sprintf([imgfiles(k).name(1:end-4),'_bf.tif']);
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_bf.tif'])); % '-r300' sets the resolution (dots per inch)


figure(2)
histogram(img(:))
BW = edge(img,'Canny');
figure(3)
imagesc(BW)

sel = strel('line',7,0); %% 7 can be modified
dil_BW = imdilate(BW,sel);
figure(4)
imagesc(dil_BW)
se = strel('disk',7); %% 7 can be modified
dil_BW_close = imclose(dil_BW,se);
figure(5)
imagesc(dil_BW_close)
se2 = strel('disk',30); %% 30 can be modified
dil_BW_close_open=imopen(dil_BW_close,se2);
figure(6)
imagesc(dil_BW_close_open)
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_mask.tif'])); 
mask_img=img.*dil_BW_close_open;
%% at this point we select a part of the masked image manually
% mask_img=mask_img(200:1200,300:800);
figure(7)
imagesc(mask_img), colormap gray

% imwrite(mask_img,fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_BFmasked.tif']),'Compression','none')
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_BFmasked.tif'])); 


flr_img=double(imread(imgfiles(k+1).name));
figure(8)
imagesc(flr_img)
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_FLUN.tif'])); 

figure(9)
histogram(flr_img(:))
filt_img=dil_BW_close_open.*flr_img;
figure(10)
imagesc(filt_img)
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_FLMask.tif'])); 

figure()
histogram(filt_img(:))
k
filt_noise=flr_img.*(~dil_BW_close_open);
figure(11)
imagesc(filt_noise)
limits=caxis
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_Noisemaskunfilt.tif'])); 

figure(12)
histogram(filt_noise(:))
nz_noise=filt_noise(filt_noise>0);
figure()
histogram(nz_noise)
noise_mean=mean(nz_noise(:))
std_noise=std(nz_noise(:))
noise_mean+4*std_noise
filt_noise(filt_noise>noise_mean+2*std_noise)=0;
figure()
imagesc(filt_noise)
caxis([limits(1) limits(2)])
print('-dtiff', '-r600', fullfile(figures_folder,[imgfiles(k).name(1:end-4),'_Noisemaskfilt.tif'])); 

nz_signal=filt_img(filt_img>0);
nz_noise=filt_noise(filt_noise>0);
figure()
histogram(nz_noise)
figure()
histogram(nz_signal)
noise_mean=mean(nz_noise(:))
std_noise=std(nz_noise(:))
SNR_std=(mean(nz_signal))/(std(nz_noise))
name=[name string(imgfiles(k+1).name)]
SNR_m=[SNR_m SNR_std]
end
%%
DataTable=table([name; SNR_m]);
 % Name of the excel file. 
writetable(DataTable,fullfile(figures_folder,'SNR.xlsx'),'Sheet',1)

close all

