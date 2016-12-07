function outmask=select_volume_from_point(coords, mask)
% SELECT VOLUME FROM POINT Support function for several other functions.
%   outmask=select_volume_from_point(coords, mask) 
%   For a starting point specified in 'coords' returns the whole connected 
%   volume in the mask.
%
%   Created by PF 6/?/2016
    
    CC = bwconncomp(mask, 6);
    L = labelmatrix(CC);
    
    outmask=zeros(size(mask));
    outmask(L==L(coords))=1;
end