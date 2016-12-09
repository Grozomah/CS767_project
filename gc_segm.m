function out=gc_segm(CTimg, PETimg, SELECTcrop)
% An example of how to segment a color image according to pixel colors.
% Fisrt stage identifies k distinct clusters in the color space of the
% image. Then the image is segmented according to these regions; each pixel
% is assigned to its cluster and the GraphCut poses smoothness constraint
% on this labeling.

out = zeros(size(CTimg));
petValues=PETimg(SELECTcrop>0);

outThresh   =quantile(petValues,0.2);
inThresh    =quantile(petValues,0.85);
disp(['In threshold: ', num2str(inThresh),', out threshold: ', num2str(outThresh)])
%% how to erode 

se = strel('square',3);

for slice=1:size(CTimg, 3);

    slicePET=PETimg(:,:,slice);
    sliceCT=CTimg(:,:,slice);
    sz = size(slicePET);

    im=zeros([sz,2]);
    im(:,:,1)=slicePET;
    im(:,:,2)=sliceCT;
    
    % try to segment the image into k different regions
    k = 2;

    % color space distance
    distance = 'sqEuclidean';

    % data cost maps - optimize this!
    Dc = zeros([sz(1:2) k],'single');

    defNotTumor = SELECTcrop(:,:,slice)-imerode(SELECTcrop(:,:,slice),se);
    defNotTumor(slicePET<outThresh)=1;
    
    Dc(:,:,1)=defNotTumor;
    Dc(:,:,2)=(slicePET>inThresh);

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