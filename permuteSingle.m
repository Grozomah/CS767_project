function outIMG=permuteSingle(SOMEimg, permut)
% PERMUTE SINGLE Support function for changing projections in GUI.
%   handles=permuteSingle(hObject, handles, permut) permutes and shifts the
%   data accordingly to the parameter specified in 'permut'.
%   The function is long, but pretty repetative and boring.
%
%   ! Keep in mind, X and Y are flipped in matlab images! (e.g. [Y,X,Z]) !
%
%   permut = {'XZ->XY', 'XY->XZ', 'XY->YZ', 'YZ->XY', 'XZ->YZ', 'YZ->XZ'}
%   Created by PF 7/8/2016

switch permut
    case 'XZ->XY'
        outIMG=permute(flipud(SOMEimg), [3,2,1]);
    case 'XY->XZ'
        outIMG=flipud(permute(SOMEimg, [3,2,1]));
    case 'XY->YZ'
        outIMG=flipud(permute(flipud(SOMEimg), [3,1,2]));
    case 'YZ->XY'
        outIMG=flipud(permute(flipud(SOMEimg), [2,3,1]));
    case 'XZ->YZ'
        outIMG=fliplr(permute((SOMEimg), [1,3,2]));
    case 'YZ->XZ'
        outIMG=(permute(fliplr(SOMEimg), [1,3,2]));
end
end