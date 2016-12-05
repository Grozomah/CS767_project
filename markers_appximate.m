function appxIMG=markers_appximate(petIMG, markIMG)
% APPROXIMATE MARKERS watershed support function.
%   appxIMG=markers_appximate(petIMG, markIMG) this function create
%   approximate image contours by variable threshold based on lesion
%   maximum SUV value.
% 
%   PETimg - 3D PET image
%   MARKimg - 3D image with point markers
%   appxIMG - output 3D binary mask
%
%   Created by PF 6/?/2016

    %% create approximate lesion regions.
    appxIMG=zeros(size(petIMG));
    CC = bwconncomp(markIMG, 6);
    L = labelmatrix(CC);
    tlist=unique(L);
    tlist=tlist(tlist>0);
    h=waitbar(0, 'Watershed 2D - approximating');

    for i=1:length(tlist)
        waitbar(i/length(tlist), h)
        idx=find(L==tlist(i));
        outmask=select_volume_from_point(idx, petIMG>max(min(petIMG(idx)*0.6, 10), 3.5));

        appxIMG(outmask>0)=i;
    end

    close(h)
end