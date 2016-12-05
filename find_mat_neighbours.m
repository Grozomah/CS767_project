function out=find_mat_neighbours(idxLst, matsize)
% FIND MATRIX NEIGHBOURS  Support function.
%   out=find_mat_neighbours(idxLst, matsize) returns a list of all
%   neighbouring elements (connect 6) to the initial index list.
% 
%   idxLst - 1D list of indeces that we're interested in
%   matsize - dimensions of the 3D matrix.
%   out - 1D index list of neighbours
%
%   see also: find, sub2ind, ind2sub
%   Created by PF 6/?/2016

    
out=[];
for i=1:length(idxLst)
    idx=idxLst(i);
    outi=[];
    if rem(idx,matsize(1))~=1 % if not on top
        outi=[outi, idx-1];    % up
    end
    if rem(idx,matsize(1))~=0 % if not on bot
        outi=[outi, idx+1];    % down
    end
    if rem(idx, matsize(1)*matsize(2))> matsize(1)
        outi=[outi, idx-matsize(1)];   % left
    end
    if rem(idx, matsize(1)*matsize(2)) < matsize(1)*(matsize(2)-1) && idx<matsize(1)*matsize(2)
        outi=[outi, idx+matsize(1)];   % right
    end
    if idx>matsize(1)*matsize(2)
        outi=[outi, idx-matsize(1)*matsize(2)];   % in
    end
    if idx<matsize(1)*matsize(2)*(matsize(3)-1)
        outi=[outi, idx+matsize(1)*matsize(2)];   % out
    end

    out=[out, outi];
end
out=unique(out);

% remove existing voxels, leaving only the neighbours
for i=1:length(idxLst)
    out(out==idxLst(i))=[];
end

end