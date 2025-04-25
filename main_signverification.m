clc;
clear all;
close all;

% Read files form pc. 
[FileName,PathName] = uigetfile('./Input_Image/*.tif;*.jpg;*.png;*.bmp',... 
                                    'Select an Input Image File');

[file_path,name,ext] = fileparts(FileName);
info = imfinfo([PathName '\' FileName]);
W = info.Width;
H = info.Height;
% Input Image Read
In_Img = (imread([PathName '\' FileName]));

figure;
imshow(In_Img);
% title('Input Image');
title(sprintf('Input Image Size %d X %d ',H,W));


[rows, columns, no_of_band] = size(In_Img);
if isequal (no_of_band,3)
	% Convert it to gray scale 
    gray = rgb2gray(In_Img);
else
    gray = In_Img;
end
figure;
imshow(gray); 
title('Gray Image');

% Filter - Preprocessing
InImg = gray;
Gs=fspecial('gaussian');
[rows1, columns1, no_of_band1] = size(InImg);
if isequal (no_of_band1,3)
	% Convert it to gray scale 
	In_fil(:,:,1)=medfilt2(double(InImg(:,:,1)));
    In_fil(:,:,2)=medfilt2(double(InImg(:,:,2)));
    In_fil(:,:,3)=medfilt2(double(InImg(:,:,3)));

else
    In_fil=medfilt2(double(InImg));
end
figure; imshow(uint8(In_fil)); title('Preprocessed Image');


% Feature Extraction
originalImage=In_Img;
corners = detectHarrisFeatures(gray);

figure;
imshow(originalImage); hold on;
plot(corners.selectStrongest(1000));
title('Input Features Image');
 points = detectBRISKFeatures(originalImage);
figure;

  imshow(originalImage); hold on;
  plot(points.selectStrongest(20));
I_thresh = im2bw(gray,graythresh(gray));

figure;
imshow(I_thresh);title('Threshold Segmentation');

load 'Train_Data.mat';

addpath(genpath('Functions'));
Train = mean(sign_feat,2);
Test = cnn(imresize(In_Img,[256 256]));
Test  = mean(Test);
CNN_Mem = ismember(Train, Test);
X = find(CNN_Mem(:,1)>0)
X = mean(X);

if (X >1 && X < 150)
    disp('Detected Status: Forgery')
    helpdlg('  Detected Author: Forgery  ');

elseif (X >=151 && X <= 300)
    disp('Detected Status: Original')
    helpdlg('  Detected Status: Original  ');

end