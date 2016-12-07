%% %% %% %% %% %% %% %% %% mat2am READ-ME %% %% %% %% %% %% %% %%
% 
% Converts a Matlab structure to an AmiraMesh (.am) file.  The input
% structure can have one of the following formats to maximize compatbility 
% with other scripts:
%
% Input 1: Geometry style
%
% input = 
%          start: [3x1 int/single/double]
%     voxel_size: [3x1 int/single/double]
%           data: [MxNxQ int/single/double]
%
% Input 2: Data style
%
% input = 
%            dims: [3x1 int]
%     boundingbox: [1x6 int/single/double]
%            xpix: int/single/double
%            ypix: int/single/double
%            zpix: int/single/double
%           image: [MxNxQ int/single/double]
%
% 
% Output 1: AmiraMeshFile can be named explicitly in char string
%   
%   mat2am(input,'AmiraMeshFileName.am');
%
% Output 2: implicity through user graphical interface:
%
%   mat2am(input);
%
% IGT authors: RTF,DLB,SRB,CHS,KCM,PG
% Revised 9/13/10
%
%% %% %% %% %% %% %% %% %% mat2am script %% %% %% %% %% %% %% %% %% %% %%

function mat2am(varargin)

switch nargin
    
    case 0
        error('Must specify Matlab structure to convert to AmiraMesh.');
    
    case 1
        
        % first input is Matlab structure
        Geometry = varargin{1};
        if ~isa(Geometry,'struct')
            error('Input must be a structure.');
        else % ensure that all of the required fields are present
            
            % check start coordinates
            if ~isfield(Geometry,'start') && ~isfield(Geometry,'boundingbox')
                error('Input must have a ''start'' or ''boundingbox'' field.');
            elseif ~isfield(Geometry,'start')
                Geometry.start = [Geometry.boundingbox(1) Geometry.boundingbox(2) Geometry.boundingbox(3)];
            elseif numel(Geometry.start) ~= 3 || ~isnumeric(Geometry.start)
                error('Geometry.start must be a 3-element vector.');
            end

            % check voxel size
            if ~isfield(Geometry,'voxel_size') && ~isfield(Geometry,'xpix')
                error('Geometry must have a ''voxel_size'' or ''pix'' field.');
            elseif ~isfield(Geometry,'voxel_size')
                Geometry.voxel_size = [Geometry.xpix Geometry.ypix Geometry.zpix];
            elseif numel(Geometry.voxel_size) ~= 3 || ~isnumeric(Geometry.voxel_size)
                error('Geometry.voxel_size field must be a 3-element vector.');
            end

            % check image data
            if ~isfield(Geometry,'data') && ~isfield(Geometry,'image')
                error('Geometry must have a ''data'' field.');
            elseif ~isfield(Geometry,'data')
                Geometry.data = Geometry.image;
            elseif ~isnumeric(Geometry.data)
                error('Geometry.data field must be a numeric array.');
            end
        end
        
        % user interface to select save directory and name AmiraMesh file
        [filename,pathname] = uiputfile('*.am','Save AmiraMesh file name');
        AmiraMeshFile = [pathname filename];
        
    case 2
       
        % first input is Matlab structure 
        Geometry = varargin{1};
        if ~isa(Geometry,'struct')
            error('Input must be a structure.');
        else % ensure that all of the required fields are present
            
            % check start coordinates
            if ~isfield(Geometry,'start') && ~isfield(Geometry,'boundingbox')
                error('Input must have a ''start'' or ''boundingbox'' field.');
            elseif ~isfield(Geometry,'start')
                Geometry.start = [Geometry.boundingbox(1) Geometry.boundingbox(2) Geometry.boundingbox(3)];
            elseif numel(Geometry.start) ~= 3 || ~isnumeric(Geometry.start)
                error('Geometry.start must be a 3-element vector.');
            end

            % check voxel size
            if ~isfield(Geometry,'voxel_size') && ~isfield(Geometry,'xpix')
                error('Geometry must have a ''voxel_size'' or ''pix'' field.');
            elseif ~isfield(Geometry,'voxel_size')
                Geometry.voxel_size = [Geometry.xpix Geometry.ypix Geometry.zpix];
            elseif numel(Geometry.voxel_size) ~= 3 || ~isnumeric(Geometry.voxel_size)
                error('Geometry.voxel_size field must be a 3-element vector.');
            end

            % check image data
            if ~isfield(Geometry,'data') && ~isfield(Geometry,'image')
                error('Geometry must have a ''data'' field.');
            elseif ~isfield(Geometry,'data')
                Geometry.data = Geometry.image;
            elseif ~isnumeric(Geometry.data)
                error('Geometry.data field must be a numeric array.');
            end
        end 

        % second input is AmiraMeshFile name
        AmiraMeshFile = varargin{2};
        if ~isa(AmiraMeshFile,'char')
            error('AmiraMeshFile must be a character array.');
        end
        
end

% extract matrix dimensions
Xcount = size(Geometry.data,1);
Ycount = size(Geometry.data,2);
Zcount = size(Geometry.data,3);

% extract bounding box coordinate vectors
boxstart = Geometry.start;
boxend(1) = boxstart(1) + Geometry.voxel_size(1)*(Xcount-1);    
boxend(2) = boxstart(2) + Geometry.voxel_size(2)*(Ycount-1);    
boxend(3) = boxstart(3) + Geometry.voxel_size(3)*(Zcount-1);    

% conversion table for data types
% 6 allowed types for Amira:
% byte, short, ushort, int32, float, double

% determine data type in Matlab and look-up Amira analog
if isa(Geometry.data,'int8')
   MatlabDataType = 'int8';
   AmiraDataType = 'byte';
elseif isa(Geometry.data,'int16')
   MatlabDataType = 'int16';
   AmiraDataType = 'short';
elseif isa(Geometry.data,'uint16')
   MatlabDataType = 'uint16';
   AmiraDataType = 'ushort';
elseif isa(Geometry.data,'int32')
   MatlabDataType = 'int32';
   AmiraDataType = 'int32';
elseif isa(Geometry.data,'single')
   MatlabDataType = 'single';
   AmiraDataType = 'float';
elseif isa(Geometry.data,'double')
   MatlabDataType = 'double';
   AmiraDataType = 'double';
else
   error('Geometry.data data type is not supported by Amira.');
end

% open the AmiraMesh file for writing text
fid = fopen(AmiraMeshFile,'w');

% write header file
fprintf(fid,'# AmiraMesh 3D BINARY 2.0\n\n');
fprintf(fid,['# CreationDate: ' datestr(now,'ddd mmm') datestr(now,' dd HH:MM:SS yyyy') '\n\n']);
fprintf(fid,'define Lattice %g %g %g\n\n',Xcount,Ycount,Zcount);
fprintf(fid,'Parameters {\n');
fprintf(fid,'    Content "%gx%gx%g %s, uniform coordinates",',Xcount,Ycount,Zcount,AmiraDataType);
fprintf(fid,'    BoundingBox %g %g %g %g %g %g,\n',boxstart(1),boxend(1),boxstart(2),boxend(2),boxstart(3),boxend(3));
fprintf(fid,'    CoordType "uniform"\n');
fprintf(fid,'}\n\n');
fprintf(fid,'Lattice { %s Data } @1\n\n',AmiraDataType);
fprintf(fid,'# Data section follows\n');
fprintf(fid,'@1\n');
fclose(fid);  % close the text part of the file

% write the data in big endian format
fid = fopen(AmiraMeshFile,'ab','ieee-be');
fwrite(fid,Geometry.data,MatlabDataType);
fclose(fid);
