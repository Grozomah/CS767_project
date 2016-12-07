function segmIMG=markers_watershed_25D(petIMG, appxIMG)
% 2.5D WATERSHED SEGMENTATION WITH MARKERS
%   segmIMG=markers_watershed_25D(petIMG, appxIMG)
%   Same as 2.5 D watershed segmentation, just with foreground markers as
%   input.
%
%   Created by PF 7/5/2016

%% tweak parameters
% thfgm=9; % foreground markers threshold: Naf: 9, FDG: 15e3
% thbgm=0.1e0; % background markers threshold: 0.1
% thsegm=8; % final decision threshold: Naf: 8

%% no touchy fishy after here.
% ( http://i.imgur.com/ZigXHzX.gifv )

    %% getting 2D watershed segmentations.
    % first projection
    seg1=int8(markers_watershed_2D(petIMG, appxIMG)>0);

    % second projection
    petIMG2=flipud(permute(petIMG, [3,2,1]));
    appxIMG2=flipud(permute(appxIMG, [3,2,1]));
    seg2=markers_watershed_2D(petIMG2, appxIMG2);
    seg2=int8(permute(flipud(seg2), [3,2,1])>0);

    % third projection
    petIMG3=flipud(permute(flipud(petIMG), [3,1,2]));
    appxIMG3=flipud(permute(flipud(appxIMG), [3,1,2]));
    seg3=markers_watershed_2D(petIMG3, appxIMG3);
    seg3=int8(flipud(permute(flipud(seg3), [2,3,1]))>0);
    
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
