function colorwash(ctIMG, petIMG, varargin)
% ctIMG - CT image in a 3D matrix form
% petIMG - PET image in a 3D matrix form
%
% Optional arguments:
% HUrange - define HU range
% SUVrange - degine SUV range
% dim - along which dim to plot: 1-xy, 2-xz, 3-yz
%
% colorwash(ctIMG, petIMG)
% colorwash(ctIMG, petIMG, HUrange, SUVrange, dim)
% colorwash(ctIMG, petIMG, [-500, 500], [0,10], 2)

%% interpret inputs
numvarargs = length(varargin);
if numvarargs > 3
    error('myfuns:somefun2Alt:TooManyInputs', ...
        'requires at most 3 optional inputs');
end
% Fill in unset optional values.
optargs = {[-500, 500], [0, 15], 1}; %default values
optargs(1:numvarargs) = varargin;
[HUrange, SUVrange, dim] = optargs{:};

% load('parula_colormap2.mat');

%% Downsample CT
petIMG = imresize(petIMG, size(ctIMG,1)/size(petIMG,1)); 

%% permute dimensions if needed
if dim==2% patient is facing out of screen (heart is on the image right)
    ctIMG=flipud(permute(ctIMG, [3, 2, 1]));
    petIMG=flipud(permute(petIMG, [3, 2, 1]));
elseif dim==3
    ctIMG=flipud(permute(ctIMG, [3, 1, 2]));
    petIMG=flipud(permute(petIMG, [3, 1, 2]));
end

%% window setup
fig=figure;
set(fig,'Name','Colorwash','Toolbar','figure',...
    'NumberTitle','off')

axes('Position',[.15 .05 .7 .9]); % Create an axes to plot in
% slice select slider
slider1_handle=uicontrol(fig,'Style','slider','Max',size(ctIMG,3),'Min',1,...
    'Value',int16(size(ctIMG,3)/2),'SliderStep',[1/(size(ctIMG,3)-1) 10/(size(ctIMG,3)-1)],...
    'Units','normalized','Position',[.02 .02 .03 .55]);

%% PET data rescaling
% percentmax-maximum of the colormap, as a fraction of the PET's maximum pixel value
petgrayIMG= -SUVrange(1)/(SUVrange(2)-SUVrange(1)) +...
            petIMG/SUVrange(2);

%% Create VARS
% this is the main parameter that gets passed around, contains all info
vars=struct('slider1_handle',slider1_handle,'CT',ctIMG, 'PET', petgrayIMG, ...
    'HUrng',HUrange, 'map', jet);  % parula_colormap2

%% Set up callbacks
set(slider1_handle,'Callback',{@slider1_callback,vars});    
plotterfcn(vars)
% End of main file
end


% Slice select function
function slider1_callback(~,~,vars)
    % whenever the slider is moved, it calls this function, which in turn
    % calls the plotter function
    vars.slider1_handle.Value=int16(get(vars.slider1_handle,'Value'));
    plotterfcn(vars)
end
    
% Plots the image
function plotterfcn(vars) 
    slice=int16(vars.slider1_handle.Value);
    imgPET = vars.PET(:,:,slice);
    imgCT = vars.CT(:,:,slice);
    %convert PET image into RGB map
    GrayIndex = uint8(floor(imgPET * 255));
    Map       = jet(255);   %= vars.map;
    RGB3      = ind2rgb(GrayIndex, Map);
    
    %show CT image, hold on, overlap PET, then apply alpha blending
    imshow(imgCT, vars.HUrng, 'InitialMag', 'fit');
    hold on
    h = imshow(RGB3);
    hold off
    % set colormap transparency
    set(h, 'AlphaData', imgPET);
    
    title(num2str(vars.slider1_handle.Value));
end

    
    
