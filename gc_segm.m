function out=gc_segm(CTimg, PETimg, SELECTcrop)
% An example of how to segment a color image according to pixel colors.
% Fisrt stage identifies k distinct clusters in the color space of the
% image. Then the image is segmented according to these regions; each pixel
% is assigned to its cluster and the GraphCut poses smoothness constraint
% on this labeling.


out = zeros(size(CTimg));

se = strel('square',3);

%% define what IS tumor
defTumor3d=zeros(size(PETimg));
petValues=PETimg(SELECTcrop>0);
defTumor3d(PETimg>min(quantile(petValues,0.85), 15))=1;


%% define what is not tumor
mse=[0 1 0; 1 1 1; 0 1 0];
se3d = strel('arbitrary',mse, ones(3));
defNotTumor3d=ones(size(PETimg))-imerode(SELECTcrop, se3d); % everything not inside the contour
SELECTedge=logical((imdilate(SELECTcrop, se3d)-1)-SELECTcrop);

% everything with values smaller than max edge value is not a lesion
defNotTumor3d(PETimg< min([max(PETimg(SELECTedge)), 10]))=1; 


outThresh   = max(PETimg(SELECTedge));
inThresh    = min(quantile(petValues,0.85), 15);
disp(['In threshold: ', num2str(inThresh),', out threshold: ', num2str(outThresh)])


for slice=1:size(CTimg, 3);

    slicePET=PETimg(:,:,slice);
    sliceCT=CTimg(:,:,slice);
    sz = size(slicePET);

    im=zeros([sz,2]);
    im(:,:,1)=slicePET;
%     max(slicePET(:))
    
    im(:,:,2)=double(sliceCT) *1e-2;
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

    mx=[1 2 1; 2 4 2; 1 2 1]/16;
    
    defNotTumor=conv2(conv2(defNotTumor, mx, 'same'), mx, 'same');
    defTumor=conv2(conv2(defTumor, mx, 'same'), mx, 'same');
    
    
    Dc(:,:,1)=defNotTumor;
    Dc(:,:,2)=(slicePET>inThresh);
    
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

for b=1:size(im,3)
    vC = max(vC, abs(imfilter(im(:,:,b), vf, 'symmetric')));
    hC = max(hC, abs(imfilter(im(:,:,b), vf', 'symmetric')));
end