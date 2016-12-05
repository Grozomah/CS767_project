%% %% %% %% %% %% %% %% %% am2mat READ-ME %% %% %% %% %% %% %% %% %% %% %%
%
% Converts an AmiraMesh (.am) file to a Matlab structure, as long as the
% .am file is written in the recognized format.

% Two types of input are accepted:
% 1) explicitly given as character string (output = am2mat('input.am');) OR
% 2) implicitly given from user graphical interface selection (am2mat;)
% 
% Example AmiraMesh file input header:
%
% # AmiraMesh BINARY-LITTLE-ENDIAN 2.1
% 
% 
% define Lattice 366 367 47
% 
% Parameters {
%     Content "366x367x47 float, uniform coordinates",
%     BoundingBox 0.0487862 49.9512 0.0487862 50.0879 0 15.042,
%     CoordType "uniform"
% }
% 
% Lattice { float Data } @1
% 
% # Data section follows
% @1
%
% For compatibility, script can yield different outputs that are used by
% other scripts:
% 
% Output 1: Geometry style (output = am2mat('input.am');)
%
% output = 
%          start: [3x1 int/single/double]
%     voxel_size: [3x1 int/single/double]
%           data: [MxNxQ int/single/double]
%
% Output 2: Geometry + Data style ([output,output2] = am2mat('input.am');
%
% output2 = 
%            dims: [3x1 int]
%     boundingbox: [1x6 int/single/double]
%            xpix: int/single/double
%            ypix: int/single/double
%            zpix: int/single/double
%           image: [MxNxQ int/single/double]
% 
% Future versions can eliminate one of the outputs provided that a consensus
% is reached within the group and scripts depending on these outptus are
% made consistent.
%
% IGT Authors: RTF, DLB, SRB, KCM, CHS, PG
% Revised 9/13/10
%
%% %% %% %% %% %% %% %% %% am2mat script %% %% %% %% %% %% %% %% %% %% %%

function [Geometry,data] = am2mat(varargin)

switch nargin 
    case 1
        filename = varargin{1};   
    case 0
        [file, pathname] = uigetfile({'*.am'},'Please locate Amira file.','Multiselect','off');
        filename = [pathname file];
end

%         [file, pathname] = uigetfile({'*.am'},'Please locate Amira file.','Multiselect','off');
%         filename = [pathname file];

% open file and read only header as character string
fid = fopen(filename,'r','ieee-be');
datachar = fread(fid,1000,'*char')'; % this will be the char data in the header

% determine endieness of data (order in which bytes are arranged)
switch isempty(findstr(datachar,'BINARY-LITTLE-ENDIAN'))
    case 1
        endianness = 'be';
    case 0
        endianness = 'le';
end

% create data structure
data = [];

% locate keywords in header that give information about the spatial
% location, voxel size, and dimensions of data matrix
lattice = findstr(datachar,'define Lattice');
start_data_position = findstr(datachar,'@1');

% extract matrix dimensions
fseek(fid,lattice+14,'bof');
data.dims = str2num(fgetl(fid)); %#ok<ST2NM>

% extract bounding box coordinates
bounding = findstr(datachar,'Bounding');
fseek(fid,bounding + 11,'bof');
data.boundingbox = str2num(fgetl(fid)); %#ok<ST2NM>

% calculate voxel size from bounding box and matrix dimensions
data.xpix = (data.boundingbox(2)-data.boundingbox(1))/double((data.dims(1)-1));
data.ypix = (data.boundingbox(4)-data.boundingbox(3))/double((data.dims(2)-1));
data.zpix = (data.boundingbox(6)-data.boundingbox(5))/double((data.dims(3)-1));

% determine if data written in full binary or label field hexadecimal binary
% format (RLE)
% full binary: 0 0 0 1 0 0 1 1
% label field: 31211
switch isempty(findstr(datachar,'HxByteRLE'))
    case 1  % regular data case
        data_type = char(datachar(findstr(datachar,'Lattice { ')+10:findstr(datachar,'Data } ')-2));
        switch data_type
            case 'byte'
                out_type = 'int8';
            case 'short'
                out_type = 'int16';
            case 'ushort'
                out_type = 'uint16'; 
            case 'int32'
                out_type = 'int32';
            case 'float'
                out_type = 'single';
            case 'double' 
                out_type = 'double';
        end
        fid = fopen(filename,'r',['ieee-' endianness]);
        fseek(fid,start_data_position(2)+2,'bof');
        
        if strcmp(data_type,'byte') 
            data.image = int8(reshape(fread(fid,data.dims(1)*data.dims(2)*data.dims(3),out_type),data.dims(1),data.dims(2),data.dims(3)));
        else
            data.image = reshape(fread(fid,data.dims(1)*data.dims(2)*data.dims(3),[data_type '=>' out_type]),data.dims(1),data.dims(2),data.dims(3));
        end

        
    case 0 % labelfield case
        ByteRLE = findstr(datachar,'HxByteRLE,');
        DataSection = findstr(datachar,'# Data section follows');
        
        fseek(fid,ByteRLE+9,'bof');
        byte_length = str2double(fread(fid,DataSection - ByteRLE-13,'*char')');

        switch endianness
            case 'le'
                fclose(fid);
                fid = fopen(filename,'r',['ieee-' endianness]);
                fseek(fid,start_data_position(2)+2,'bof');
                data.image = fread(fid,byte_length,'int8');
            case 'be'
                fseek(fid,start_data_position(2)+2,'bof');
                data.image = fread(fid,byte_length,'int8');
        end

        out_line = zeros(data.dims(1)*data.dims(2)*data.dims(3),1);

        final_offset = sum(data.image(data.image<0)+127);

        net_counter = 0;  % this sifts through the out_line variable
        offset = 0;  % this adds an offset to data_counter when writing VERBATIM

        for i = 1:floor((byte_length-final_offset)/2) % 
            data_counter = 2*i+offset;  % this will sift through the data variable
            if ((data.image(data_counter) == 0) && (data.image(data_counter-1) > 0)) % check if the value is 0 AND that we're not writing VERBATIM
                net_counter = data.image(data_counter-1)+net_counter;
            else
                if data.image(data_counter-1) < 0 % check if we're writing VERBATIM
                    for j = 1:128+data.image(data_counter-1)
                        out_line(j+net_counter) = data.image(data_counter+j-1);
                    end
                    net_counter = 128+data.image(data_counter-1)+net_counter;
                    offset = offset + 127+ data.image(data_counter-1);
                else  % assume that we're copying value data(data_counter), data(data_counter-1) times.
                    for j = 1:data.image(data_counter-1)
                        out_line(j+net_counter) = data.image(data_counter);
                    end
                    net_counter = data.image(data_counter-1)+net_counter;
                end
            end
        end 

        data.image = reshape(out_line,data.dims(1),data.dims(2),data.dims(3));
               
end

% create Geometry structure
Geometry = [];
Geometry.start = [data.boundingbox(1) data.boundingbox(3) data.boundingbox(5)];
Geometry.voxel_size = [data.xpix data.ypix data.zpix];
Geometry.data = data.image;

fclose all;

end