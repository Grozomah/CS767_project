function segmIMG=watershed_2D(petIMG)
% 2D WATERSHED SEGMENTATION - a good and fast whole-body segmentation
%   method.
%   segmIMG=watershed_2D(petIMG)
%   Using function parameters specified below, this function attempts to
%   segment the PET image provided when calling function. It returns a mask
%   of lesions.
%
%   Generally does a good job (better than thresholding), but can
%   occasionally spill - be attentive!
%
%   Created by PF 6/?/2016

%% Function parameters
alpha=1;
thfgm=alpha*9; % foreground markers threshold: Naf: 9, FDG: 15e3
thbgm=alpha*0.1; % background markers threshold: 0.1
thsegm=alpha*8; % final decision threshold: Naf: 8


%% no touchy fishy after here.
% ( http://i.imgur.com/ZigXHzX.gifv )
segmIMG=zeros(size(petIMG));
h=waitbar(0, 'Watershed 2D');

for sliceN= 1:size(petIMG,3)
    
    waitbar(sliceN/size(petIMG,3))
    I=alpha*petIMG(:,:,sliceN);
    %% select single slice
    if max(I(:))<7  % ignore low SUV slices
       segmIMG(:,:,sliceN)=zeros(size(I));
       continue
    end
    
    %% calculate raw 2D gradient image
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);

    %% Prepare the gradient image for watershed
    % define foreground markers - lesion seeds
    se2 = strel(ones(2,2)); % smooth mask, to fill in any jagged edges
    fgm = imclose(I>thfgm, se2);   
    % define background markers - out of body regions, etc.
    bgm=imclose(I<thbgm, se2);
    % impose minimum on objects definitely inside and def outside
    gradmag2 = imimposemin(gradmag, bgm | fgm);   
    
    %% Compute the Watershed Transform of the Segmentation Function.
    L = watershed(gradmag2);

    %% output data prep
    outI=zeros(size(I));
    % decide which watershed defined areas are lesions
    for i=min(L(:)):max(L(:))
        if mean(I(L==i))>thsegm
            outI(L==i)=1;
        end
    end
    segmIMG(:,:,sliceN)=outI;
end

%     se3 = strel('disk', 1);
    se3 = strel('ball', 1,1, 0);
    segmIMG2=imdilate(segmIMG, se3)-1;

    CC=bwconncomp(segmIMG2);
    segmIMG2 = labelmatrix(CC);
    
    close(h)
end


