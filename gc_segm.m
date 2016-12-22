function out=gc_segm(CTcrop, PETcrop, SELECTcrop)
% Perform 2d graph cut segmentation based on the PET and CT images, and
% using SELECT as the area 



%% attempted transformation fix
truncated=(PETcrop-15)/20 +15;
PETcrop(PETcrop>15) = truncated(PETcrop>15);

%% 
out = zeros(size(CTcrop));

se = strel('square',3);

%% define what IS tumor
defTumor3d=zeros(size(PETcrop));
petValues=PETcrop(SELECTcrop>0);
defTumor3d(PETcrop>min(quantile(petValues,0.75), 15))=1;

temp=(PETcrop-5)/10;
idx= (PETcrop>5 & PETcrop<=min(quantile(petValues,0.75), 15));
defTumor3d(idx)=temp(idx);

% defTumor3d(PETimg>10)=1;
% defTumor3d = smooth3(defTumor3d,'gaussian',3);


%% define what is not tumor
mse=[0 1 0; 1 1 1; 0 1 0];
se3d = strel('arbitrary',mse, ones(3));
SELECTedge=logical((imdilate(SELECTcrop, se3d)-1)-SELECTcrop);

defNotTumor3d=ones(size(PETcrop))-imerode(SELECTcrop, se3d); % everything not inside the contour
% everything with values smaller than max edge value is not a lesion
% defNotTumor3d(PETimg< min([max(PETimg(SELECTedge)), 10]))=1; 
defNotTumor3d(PETcrop< max(4, quantile(petValues,0.75)))=1; 
% defNotTumor3d = smooth3(defNotTumor3d,'gaussian',3);

temp=(14-PETcrop)/10;
defNotTumor3d(PETcrop<15)=temp(PETcrop<15);




outThresh   = max(quantile(PETcrop(SELECTedge), 0.95), 5);
inThresh    = min(quantile(petValues,0.85), 15);
disp(['In threshold: ', num2str(inThresh),', out threshold: ', num2str(outThresh)])


for slice=1:size(CTcrop, 3);

    slicePET=PETcrop(:,:,slice);
    sliceCT=CTcrop(:,:,slice);
    sz = size(slicePET);

    im=zeros([sz,2]);
    im(:,:,1)=slicePET *1e1;
%     max(slicePET(:))
    
    im(:,:,2)=double(sliceCT) *1e1;
    a=im(:,:,2);
%     max(a(:))
    
    % try to segment the image into k different regions
    k = 2;

    % color space distance
    distance = 'sqEuclidean';

    % data cost maps - optimize this!
    Dc = zeros([sz(1:2) k],'single');

%     defNotTumor = SELECTcrop(:,:,slice)-imerode(SELECTcrop(:,:,slice),se);
%     defNotTumor(slicePET<outThresh)=1;
%     defTumor=double(slicePET>inThresh);
    defNotTumor = defNotTumor3d(:,:,slice);
    defTumor=defTumor3d(:,:,slice);
    
    if sum(defTumor(:))==0
        out(:,:,slice)=zeros(size(slicePET));
        continue
    end
    

    mx=[1 2 1; 2 4 2; 1 2 1]/16;
    
%     defNotTumor=conv2(conv2(defNotTumor, mx, 'same'), mx, 'same');
%     defTumor=conv2(conv2(defTumor, mx, 'same'), mx, 'same');
    
    
    Dc(:,:,1)=defNotTumor;
    Dc(:,:,2)=defTumor;
    
%     disp(slice)
    
    %% cut the graph 
    % smoothness term: 
    % constant part
    Sc = ones(k) - eye(k);
    % spatialy varying part
    % [Hc Vc] = gradient(imfilter(rgb2gray(im),fspecial('gauss',[3 3]),'symmetric'));
    [Hc Vc] = SpatialCues(im);

    gch = GraphCut('open', Dc, 10*Sc, exp(-Vc*5), exp(-Hc*5));
    % [gch] = GraphCut('open', DataCost, SmoothnessCost, vC, hC);
    %  vC, hC:optional arrays defining spatialy varying smoothness cost.
    [gch L] = GraphCut('expand',gch);
    % [gch labels] = GraphCut('expand', gch)
    gch = GraphCut('close', gch);
    %  'close': Close the graph and release allocated resources.
    %  [gch] = GraphCut('close', gch);
    
    %% make sure the lesion is the one with values 1, not outside
    if mean(slicePET(L>0)) < mean(slicePET(L==0))
        outSlice= int8(L==0);
    else
        outSlice= int8(L>0);
    end
    
    out(:,:,slice) = outSlice;
    
%     out(:,:,slice) = int8(Dc(:,:,1));
end     % end for each slice



% Aux functions
%-----------------------------------------------%
function [hC vC] = SpatialCues(im)
g = fspecial('gauss', [13 13], sqrt(13));
dy = fspecial('sobel');
vf = conv2(g, dy, 'valid');
sz = size(im);

vC = zeros(sz(1:2));
hC = vC;

for b=1:size(im,3) % combine change from CT and PET 
%     vC = max(vC, abs(imfilter(im(:,:,b), vf, 'symmetric')));
%     hC = max(hC, abs(imfilter(im(:,:,b), vf', 'symmetric')));
    
    vC = (vC+ abs(imfilter(im(:,:,b), vf, 'symmetric')));
    hC = (hC+ abs(imfilter(im(:,:,b), vf', 'symmetric')));
    
end



