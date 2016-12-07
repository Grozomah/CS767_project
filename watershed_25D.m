function segmIMG=watershed_25D(petIMG)
% 2.5D WATERSHED SEGMENTATION - a good and fast whole-body segmentation
%   method.
%   segmIMG=watershed_25D(petIMG)
%   This function calls 2D watershed segmentation three times - once for
%   each projection, and then combines the result into a final image.
%   Reduces the risk of splills and generally performs better.
%
%   Created by PF 6/?/2016
    %% getting 2D watershed segmentations.
    % first projection
    seg1=watershed_2D(petIMG);

    % second projection
    petIMG2=flipud(permute(petIMG, [3,2,1]));
    seg2=watershed_2D(petIMG2);
    seg2=permute(flipud(seg2), [3,2,1]);

    % third projection
    petIMG3=flipud(permute(flipud(petIMG), [3,1,2]));
    seg3=watershed_2D(petIMG3);
    seg3=flipud(permute(flipud(seg3), [2,3,1]));
    
    %% combining the 2D segmentations
    Sseg=seg1+seg2+seg3;
    segmIMG=zeros(size(petIMG));
%     out=smooth_matx_3D(Sseg);
    Sseg = smooth3(Sseg,'box',3);
    
    segmIMG(Sseg>1)=1;
    
    se = strel(ones(2,2,2));
    segmIMG=imclose(segmIMG, se);
    disp('Watershed 2.5D completed')
end