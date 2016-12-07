function orthoslice(data, varargin)
% Plot orthoslice of data. 
% format: orthoslice(data, HUrange, dim)
%
% Example: 
% orthoslice(data)
% orthoslice(data, [-500, 500], 1)
%
% data - in a 3D matrix form
% HUrange - how to grayscale the image: [-500, 500]
% dim - along which dim to plot: 1-xy, 2-xz, 3-yz

numvarargs = length(varargin);
if numvarargs > 2
    error('myfuns:somefun2Alt:TooManyInputs', ...
        'requires at most 2 optional inputs');
end
% Fill in unset optional values.
optargs = {[-500, 500] 1}; %default values
optargs(1:numvarargs) = varargin;
[HUrange, dim] = optargs{:};

%% start
if dim==2
    data=flipud(permute(data, [3, 2, 1]));
    % patient is facing out of screen (heart is on the image right)
elseif dim==3
    data=flipud(permute(data, [3, 1, 2]));
end

fig=figure;
set(fig,'Name','Orthoslice','Toolbar','figure',...
    'NumberTitle','off')
% Create an axes to plot in
axes('Position',[.15 .05 .7 .9]);
% sliders for epsilon and lambda
slider1_handle=uicontrol(fig,'Style','slider','Max',size(data,3),'Min',1,...
    'Value',int16(size(data,3)/2),'SliderStep',[1/(size(data,3)-1) 10/(size(data,3)-1)],...
    'Units','normalized','Position',[.02 .02 .03 .55]);

% Set up callbacks
vars=struct('slider1_handle',slider1_handle,'B',data);

set(slider1_handle,'Callback',{@slider1_callback,vars, HUrange});
plotterfcn(vars, HUrange)
% End of main file

% Callback subfunctions to support UI actions
function slider1_callback(~,~,vars, HUrange)
    % Run slider1 which controls value of epsilon
    plotterfcn(vars, HUrange)

    % Plots the image
function plotterfcn(vars, HUrange) 
    % sets slider to int value
    slice=int16(vars.slider1_handle.Value);
    imshow(vars.B(:,:, slice),HUrange);
    title(num2str(slice));

