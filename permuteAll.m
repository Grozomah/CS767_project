function handles=permuteAll(hObject, handles, permut)
% PERMUTE ALL Support function for changing projections in GUI.
%   handles=permuteAll(hObject, handles, permut) permutes and shifts the
%   data accordingly to the parameter specified in 'permut'.
%   The function is long, but pretty repetative and boring.
%
%   ! Keep in mind, X and Y are flipped in matlab images! (e.g. [Y,X,Z]) !
%
%   permut = {'XZ->XY', 'XY->XZ', 'XY->YZ', 'YZ->XY', 'XZ->YZ', 'YZ->XZ'}
%   Created by PF 6/?/2016

switch permut
    %% case 1
    case 'XZ->XY'
        if handles.flagCT==1; % permute CT image, if loaded.
            handles.CTimg=permute(flipud(handles.CTimg), [3,2,1]);
            handles.matsize=size(handles.CTimg);
        end
        if handles.flagPET==1; % permute PET image, if loaded.
            handles.PETimg=permute(flipud(handles.PETimg), [3,2,1]);
            handles.PETimgSUV=permute(flipud(handles.PETimgSUV), [3,2,1]);
            handles.matsize=size(handles.PETimg);
        end
        if handles.flagREFCONT==1   % permute REFCONT image, if loaded.
            handles.REFCONTimg=permute(flipud(handles.REFCONTimg), [3,2,1]);
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagSEGM==1  % permute SEGM image, if loaded.
            handles.SEGMimg=permute(flipud(handles.SEGMimg), [3,2,1]);
        end
        if handles.flagPOINT==1 % permute POINT coords, if loaded.
            Y=handles.coord_Z;
            Z=handles.matsize(3)+1-handles.coord_Y;
            handles.coord_Y=Y;
            handles.coord_Z=Z;
            handles.XYZ_Y.String=num2str(handles.coord_Y);
            handles.XYZ_Z.String=num2str(handles.coord_Z);
        end
        if handles.flagSELECT==1    % permute SELECT image, if loaded.
            handles.SELECTimg=permute(flipud(handles.SELECTimg), [3,2,1]);
        end
        if handles.flagGANAR==1 % permute GANAR image, if loaded.
            handles.GANARimg=permute(flipud(handles.GANARimg), [3,2,1]);
        end
    %% case 2
    case 'XY->XZ'
        if handles.flagCT==1; % permute CT image, if loaded.
            handles.CTimg=flipud(permute(handles.CTimg, [3,2,1]));
            handles.matsize=size(handles.CTimg);
        end
        if handles.flagPET==1; % permute PET image, if loaded.
            handles.PETimg=flipud(permute(handles.PETimg, [3,2,1]));
            handles.PETimgSUV=flipud(permute(handles.PETimgSUV, [3,2,1]));
            handles.matsize=size(handles.PETimg);
        end
        if handles.flagREFCONT==1   % permute REFCONT image, if loaded.
            handles.REFCONTimg=flipud(permute(handles.REFCONTimg, [3,2,1]));
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagSEGM==1  % permute SEGM image, if loaded.
            handles.SEGMimg=flipud(permute(handles.SEGMimg, [3,2,1]));
        end
        if handles.flagPOINT==1 % permute POINT coords, if loaded.
            Y=handles.matsize(1)+1-handles.coord_Z;
            Z=handles.coord_Y;
            handles.coord_Y=Y;
            handles.coord_Z=Z;
            handles.XYZ_Y.String=num2str(handles.coord_Y);
            handles.XYZ_Z.String=num2str(handles.coord_Z);
        end
        if handles.flagSELECT==1    % permute SELECT image, if loaded.
            handles.SELECTimg=flipud(permute(handles.SELECTimg, [3,2,1]));
        end
        if handles.flagGANAR==1 % permute GANAR image, if loaded.
            handles.GANARimg=flipud(permute(handles.GANARimg, [3,2,1]));
        end
    %% case 3
    case 'XY->YZ'
        if handles.flagCT==1; % permute CT image, if loaded.
            handles.CTimg=flipud(permute(flipud(handles.CTimg), [3,1,2]));
            handles.matsize=size(handles.CTimg);
        end
        if handles.flagPET==1; % permute PET image, if loaded.
            handles.PETimg=flipud(permute(flipud(handles.PETimg), [3,1,2]));
            handles.PETimgSUV=flipud(permute(flipud(handles.PETimgSUV), [3,1,2]));
            handles.matsize=size(handles.PETimg);
        end
        if handles.flagREFCONT==1   % permute REFCONT image, if loaded.
            handles.REFCONTimg=flipud(permute(flipud(handles.REFCONTimg), [3,1,2]));
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagSEGM==1  % permute SEGM image, if loaded.
            handles.SEGMimg=flipud(permute(flipud(handles.SEGMimg), [3,1,2]));
        end
        if handles.flagPOINT==1 % permute POINT coords, if loaded.
            X=handles.matsize(2)+1-handles.coord_Y;
            Y=handles.matsize(1)+1-handles.coord_Z;
            Z=handles.coord_X;
            
            handles.coord_X=X;
            handles.coord_Y=Y;
            handles.coord_Z=Z;
            handles.XYZ_X.String=num2str(handles.coord_X);
            handles.XYZ_Y.String=num2str(handles.coord_Y);
            handles.XYZ_Z.String=num2str(handles.coord_Z);
        end
        if handles.flagSELECT==1    % permute SELECT image, if loaded.
            handles.SELECTimg=flipud(permute(flipud(handles.SELECTimg), [3,1,2]));
        end
        if handles.flagGANAR==1 % permute GANAR image, if loaded.
            handles.GANARimg=flipud(permute(flipud(handles.GANARimg), [3,1,2]));
        end
    %% case 4
    case 'YZ->XY'
        if handles.flagCT==1; % permute CT image, if loaded.
            handles.CTimg=flipud(permute(flipud(handles.CTimg), [2,3,1]));
            handles.matsize=size(handles.CTimg);
        end
        if handles.flagPET==1; % permute PET image, if loaded.
            handles.PETimg=flipud(permute(flipud(handles.PETimg), [2,3,1]));
            handles.PETimgSUV=flipud(permute(flipud(handles.PETimgSUV), [2,3,1]));
            handles.matsize=size(handles.PETimg);
        end
        if handles.flagREFCONT==1   % permute REFCONT image, if loaded.
            handles.REFCONTimg=flipud(permute(flipud(handles.REFCONTimg), [2,3,1]));
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagSEGM==1  % permute SEGM image, if loaded.
            handles.SEGMimg=flipud(permute(flipud(handles.SEGMimg), [2,3,1]));
        end
        if handles.flagPOINT==1 % permute POINT coords, if loaded.
            X=handles.coord_Z;
            Y=handles.matsize(2)+1-handles.coord_X;
            Z=handles.matsize(3)+1-handles.coord_Y;
            
            handles.coord_X=X;
            handles.coord_Y=Y;
            handles.coord_Z=Z;
            handles.XYZ_X.String=num2str(handles.coord_X);
            handles.XYZ_Y.String=num2str(handles.coord_Y);
            handles.XYZ_Z.String=num2str(handles.coord_Z);
        end
        if handles.flagSELECT==1    % permute SELECT image, if loaded.
            handles.SELECTimg=flipud(permute(flipud(handles.SELECTimg), [2,3,1]));
        end
        if handles.flagGANAR==1 % permute GANAR image, if loaded.
            handles.GANARimg=flipud(permute(flipud(handles.GANARimg), [2,3,1]));
        end
    %% case 5
    case 'XZ->YZ'
        if handles.flagCT==1; % permute CT image, if loaded.
            handles.CTimg=fliplr(permute((handles.CTimg), [1,3,2]));
            handles.matsize=size(handles.CTimg);
        end
        if handles.flagPET==1; % permute PET image, if loaded.
            handles.PETimg=fliplr(permute((handles.PETimg), [1,3,2]));
            handles.PETimgSUV=fliplr(permute((handles.PETimgSUV), [1,3,2]));
            handles.matsize=size(handles.PETimg);
        end
        if handles.flagREFCONT==1   % permute REFCONT image, if loaded.
            handles.REFCONTimg=fliplr(permute((handles.REFCONTimg), [1,3,2]));
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagSEGM==1  % permute SEGM image, if loaded.
            handles.SEGMimg=fliplr(permute((handles.SEGMimg), [1,3,2]));
        end
        if handles.flagPOINT==1 % permute POINT coords, if loaded.
            X=handles.matsize(2)-handles.coord_Z;
            Y=handles.coord_Y;
            Z=handles.coord_X;
            
            handles.coord_X=X;
            handles.coord_Y=Y;
            handles.coord_Z=Z;
            handles.XYZ_X.String=num2str(handles.coord_X);
            handles.XYZ_Y.String=num2str(handles.coord_Y);
            handles.XYZ_Z.String=num2str(handles.coord_Z);
        end
        if handles.flagSELECT==1    % permute SELECT image, if loaded.
            handles.SELECTimg=fliplr(permute((handles.SELECTimg), [1,3,2]));
        end
        if handles.flagGANAR==1 % permute GANAR image, if loaded.
            handles.GANARimg=fliplr(permute((handles.GANARimg), [1,3,2]));
        end
    %% case 6
    case 'YZ->XZ'
        if handles.flagCT==1; % permute CT image, if loaded.
            handles.CTimg=(permute(fliplr(handles.CTimg), [1,3,2]));
            handles.matsize=size(handles.CTimg);
        end
        if handles.flagPET==1; % permute PET image, if loaded.
            handles.PETimg=(permute(fliplr(handles.PETimg), [1,3,2]));
            handles.PETimgSUV=(permute(fliplr(handles.PETimgSUV), [1,3,2]));
            handles.matsize=size(handles.PETimg);
        end
        if handles.flagREFCONT==1   % permute REFCONT image, if loaded.
            handles.REFCONTimg=(permute(fliplr(handles.REFCONTimg), [1,3,2]));
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagSEGM==1  % permute SEGM image, if loaded.
            handles.SEGMimg=(permute(fliplr(handles.SEGMimg), [1,3,2]));
            handles.matsize=size(handles.REFCONTimg);
        end
        if handles.flagPOINT==1 % permute POINT coords, if loaded.
            X=handles.coord_Z;
            Y=handles.coord_Y;
            Z=handles.matsize(2)-handles.coord_X;
            
            handles.coord_X=X;
            handles.coord_Y=Y;
            handles.coord_Z=Z;
            handles.XYZ_X.String=num2str(handles.coord_X);
            handles.XYZ_Y.String=num2str(handles.coord_Y);
            handles.XYZ_Z.String=num2str(handles.coord_Z);
        end
        if handles.flagSELECT==1    % permute SELECT image, if loaded.
            handles.SELECTimg=(permute(fliplr(handles.SELECTimg), [1,3,2]));
        end
        if handles.flagGANAR==1 % permute GANAR image, if loaded.
            handles.GANARimg=(permute(fliplr(handles.GANARimg), [1,3,2]));
        end
        
end
end