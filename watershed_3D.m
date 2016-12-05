function segmIMG=watershed_3D(petIMG)
% 3D WATERSHED SEGMENTATION - a crappy segmentation method. Work in
%   progress.
%   segmIMG=watershed_3D(petIMG)
%   Using function parameters specified below, this function attempts to
%   segment the PET image provided when calling function. It returns a mask
%   of lesions.
%
%   Created by PF 6/?/2016

segmIMG=zeros(size(petIMG));
h=waitbar(0, 'Watershed');

I=petIMG;

%% step 2 / calculate raw gradient image !! 2D FILTER SO FAR
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
% gradmag = sqrt(Ix.^2 + Iy.^2);

[px,py,pz] = gradient(I, 1, 1, 1);
G = sqrt(px.^2 + py.^2+ pz.^2);

%% step 3 - remove small objects without blurring the image
se = strel('ball', 2, 2, 0);      %% STREL param here!
Ge = imerode(G, se);
h=waitbar(1/8);
Gobr = imreconstruct(Ge, G);
h=waitbar(2/8);
Gobrd = imdilate(Gobr, se);
h=waitbar(3/8);
Gobrcbr = imreconstruct(imcomplement(Gobrd), imcomplement(Gobr));
h=waitbar(4/8);
Gobrcbr = imcomplement(Gobrcbr);    % a better way of removing the small objects

G2=Gobrcbr;

%% define foreground markers - lesion seeds
se2 = strel('ball', 1, 1, 0);

fgm = imclose(double(I>12), se2);   % smooth the mask, filling in any jagged edges
h=waitbar(5/8);
%% define background markers
bgm=imclose(double(I<0.1), se2);
h=waitbar(6/8);

gradmag=(G2);


%% Step 5: Compute the Watershed Transform of the Segmentation Function.
gradmag2 = imimposemin(gradmag, bgm | fgm);    % impose minimum on objects definitely inside and def. outside
%     imshow(gradmag2, [0, 10])
h=waitbar(7/8);

L = watershed(gradmag2);
%     imshow(L, [0,max(L(:))])

%% output data prep


outI=zeros(size(I));
for i=0:max(L(:))
    if mean(I(L==i))>4 || max(I(L==i))>15
        outI(L==i)=1;
        i
    end
end
h=waitbar(8/8);
segmIMG=outI;


close(h)
disp('done')
end


