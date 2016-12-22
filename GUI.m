%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
%   cd ('E:\005-faks\CS767\CS767_project')
%
%% Summary:
%   This is the Graphic User Interface program used to test image
%   segmentation. Just run the script, and let the button-clicking fun begin!
%
% Reading tips:
%   - Right click anywhere in editor->code folding->fold all 
%   	this will collapse all the code, making an overview much easier.
%   - Type "guide" in matlab, and open GUI.fig. GO through callback
%       functions of various buttons/fields to see what they do.
%   - Ctrl+D while highlighting function name will jump you to function
%       called, or open it in new tab.
%   - Ctrl+F2 creates a bookmark. F2 scrolls through bookmarks.
%
% Input:
%   None! You load via load buttons in the program.
% Outputs:
%   None! You export via save button in the program.
%
%   ---
% Subroutines:
%   am2mat.m
%   mat2am.m
%   nrrdread.m
%   nrrdWrite.m
%
%   Compare_segmentations.m
%   find_mat_neighbours.m
%   Get_opt_thresh.m
%   LesStats_GUI.m
%   markers_approcimate.m
%   markers_watershed_2D.m
%   markers_watershed_25D.m
%   matching_GUI.m
%   permuteAll.m
%   permuteSingle.m
%   select_volume_from_point.m
%   watershed_2D.m
%   watershed_3D.m
%   watershed_25D.m
%   gc_segm.m
%   gc_segm25D.m
%   ---
%
% Links to:
%   GANAR (make sure to addpath to it)
%
% Matlab version:
% 2015a
% Initially created: 5/18/2015 by Peter Ferjancic
% Last updated this text: 12/16/2016 by PF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% General programming notes:
%   -Don't touch GUI function
%   -You can put opening definitions in: GUI_OpeningFcn
%   -hObject is the object handle: in callback functions it contains the
%       params of the object calling the function. Use it to find UI values.
%   - ~ is a placeholder for a variable that you don't use. 
%   -handles is where the paycheck is at. This baby contains everything
%       noteworthy in the program - image data, parameter values etc.
%   - when calling custom functions that change handles, use:
%       "guidata(handles.figure1,handles);" to force handle update.
%       Otherwise the function calling it keeps using old handle values!!
%   - print message to program console by: 
%       handles.console.String=['> Mytext'];
%
    % hObject    handle to loadCT_Callback (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   To do:
%   - move to IGT gitlab after project submission
%   - try implementing the 3d graph cuts method version
%   - nrrd saving (done, but there are probably still bugs - use with care)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd('E:\010-work\Segmentation\GUI')

%% Initialization functions
%--- Hic sunt dracones
function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI
% Last Modified by GUIDE v2.5 21-Dec-2016 17:39:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})  %real code
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end
% --- Executes just before GUI is made visible, sets initial values.
function GUI_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % ~  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to GUI (see VARARGIN)
    % Choose default command line output for GUI

    handles.output = hObject;
    
    %% starting definitions
    handles.flagCT=0;       % 1 if CT image is loaded
    handles.flagPET=0;      % 1 if PET image is loaded
    handles.flagREFCONT=0;  % 1 if reference contours are loaded (purple)
    handles.flagSEGM=0;     % 1 if there are active work contours (green)
    handles.flagPOINT=0;    % 1 if the pointer is placed (X)
    handles.flagSELECT=0;   % 1 if a contour is selected (white)
    handles.flagGANAR=0;    % 1 if a GANAR produced contour is present
    
    handles.HUmin=-500;
    handles.HUmax=500;
    handles.SUVmin=0;
    handles.SUVmax=15;
     
    handles.slice=0;
    handles.matsize=[256, 256, 2];
    handles.coord_X=128;
    handles.coord_Y=128;
    handles.coord_Z=240;
    
    handles.thresh_SUV=15;
    handles.thresh_SUV=-handles.SUVmin/(handles.SUVmax-handles.SUVmin) + ...
        handles.thresh_SUV/handles.SUVmax;
    handles.thresh_grow_SUV=10;
    handles.thresh_grow =-handles.SUVmin/(handles.SUVmax-handles.SUVmin) + ...
        handles.thresh_SUV/handles.SUVmax;
    
    handles.projection_old=1;
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes GUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end
% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(~, ~, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % ~  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end


%% Loading functions
function loadCT_Callback(hObject, ~, handles)
    % Select and load CT image
    [CT_in, CT_path, ~] = uigetfile([handles.filepath.String,'\*.am;*.nrrd']);
    
    if CT_in==0 % no file selected, no change to CT data
        handles.loadtextCT.String='None!';
        handles.flagCT=0;
        handles.CTimg=ones(handles.matsize);
        handles.console.String='> No CT image selected!';
    else 
        handles.loadtextCT.String=CT_in;
        % load the CT data
        handles=LoadDataCall(handles, CT_path, CT_in, 'CT');
        % reset slider position, and redraw the figure
        handles=sliceSelect_recalibration(hObject, handles);

        % remember the last folder
        handles.filepath.String=CT_path;
    end
end
function loadPET_Callback(hObject, ~, handles)
    % Select and load PET image
    [PET_in, PET_path, ~] = uigetfile([handles.filepath.String,'\*.am;*.nrrd']);
    if PET_in==0
        handles.loadtextPET.String='None!';
        handles.PETdata=[];
        handles.flagPET=0;
        handles.console.String='> No PET image selected!';
    else
        handles.loadtextPET.String=PET_in;
        % load PET data
        handles=LoadDataCall(handles, PET_path, PET_in, 'PET');
        % reset slider position, and redraw the figure
        handles=sliceSelect_recalibration(hObject, handles);
        % remember the last folder
        handles.filepath.String=PET_path;
    end
end
function loadREFCONT_Callback(hObject, ~, handles)
    % Select and load existing contour image
    [REFCONT_in, REFCONT_path, ~] = uigetfile([handles.filepath.String,'\*.am;*.nrrd']);
    if REFCONT_in==0
        handles.loadtextCONT.String='None!';
        REFCONTdata=[];
        handles.flagREFCONT=0;
        handles.console.String='> No CONTOUR image selected!';
    else
        handles.loadtextCONT.String=REFCONT_in;
        % load reference contour data
        handles=LoadDataCall(handles, REFCONT_path, REFCONT_in, 'REFCONT');
        % reset slider position, and redraw the figure
        handles=sliceSelect_recalibration(hObject, handles);
        
        % remember the last folder
        handles.filepath.String=REFCONT_path;
    end
end
function Quickload_Callback(hObject, ~, handles)
    % one button press data prep. Change freely to whatever you use.
    handles.console.String=['> Quickloading ...'];
    drawnow
    
    if handles.Quickload_patname.String=='1'
        CT_in='1001B_B1_1ct.am';
        CT_path='E:\010-work\1001B\B1\Processed\';
        PET_in='1001B_B1_1pet_recon1_SUV.am';
        PET_path='E:\010-work\1001B\B1\Processed\';
        REFCONT_in='1001B_B1_physiciancontours.am';
        REFCONT_path='E:\010-work\1001B\B1\Processed\';
    else
        patname=handles.Quickload_patname.String;
        disp(patname)
        CT_in=[patname, '_B1_1ct.am'];
        CT_path=['\\L1220-IMAC\Data_2\Jeraj\PCF\',patname,'\B1\Processed\'];
        PET_in=[patname, '_B1_1pet_recon1_SUV.am'];
        PET_path=['\\L1220-IMAC\Data_2\Jeraj\PCF\',patname,'\B1\Processed\'];
        REFCONT_in=[patname, '_B1_physiciancontours.am'];
        REFCONT_path=['\\L1220-IMAC\Data_2\Jeraj\PCF\',patname,'\B1\Processed\'];
    end

% CT load
    handles=LoadDataCall(handles, CT_path, CT_in, 'CT');
    handles=sliceSelect_recalibration(hObject, handles);
    drawnow
% PET in
    handles=LoadDataCall(handles, PET_path, PET_in, 'PET');
    handles=sliceSelect_recalibration(hObject, handles);
    drawnow
% Ref Contours in
    handles=LoadDataCall(handles, REFCONT_path, REFCONT_in, 'REFCONT');
    handles=sliceSelect_recalibration(hObject, handles);
    handles.console.String=['> Quickload completed.'];
    
end
function Quickload_patname_Callback(hObject, ~, handles)
    % nothing happens here really. GUI just needs a function for that
    % window, but everything else looks straight at 
    % handles.Quickload_patname.String
end

%% LoadData is where the actual loading is done
function handles=LoadDataCall(handles, path, file, modality)
    % Loads the data, permutes it, resizes CT, raises appropriate flag
    handles.console.String=['> Loading ',modality,' ',file,'...'];
    drawnow
    
    switch modality %which modality is being loaded?
        case 'CT'
            handles.loadtextCT.String=file;
            [~, CT_name, ext]=fileparts(file);
            switch ext
                case '.am'
                    CTdata=am2mat([path, file]);
                    handles.CTimg=permute(CTdata.data, [2, 1, 3]);
                case '.nrrd'
                    handles.CTimg=nrrdread([path, file]);
            end
            
            handles.flagCT=1;
            if handles.flagPET==1;
                ratio=size(handles.PETimg, 2)/size(handles.CTimg, 2); % PET size  
                
                handles.CTimg = imresize(handles.CTimg, ratio); % resize CT img 
                axes=gca; % get current axes in case of zoom
                set(gca,{'xlim','ylim'}, {axes.XLim*ratio, axes.YLim*ratio})  % reset axes to what they should be
            end
            handles.matsize=size(handles.CTimg);
            
        case 'PET'
            handles.loadtextPET.String=file;
            [~, CT_name, ext]=fileparts(file);
            switch ext
                case '.am'
                    PETdata=am2mat([path, file]);
                    handles.PETimgSUV  =permute(PETdata.data, [2, 1, 3]);
                    handles.voxel_size=PETdata.voxel_size; % needed for export 
                    handles.image_coord_start=PETdata.start;
                case '.nrrd'
                    [handles.PETimgSUV, meta]=nrrdread([path, file]);
                    
                    % this extracts the voxel dimensions from metadata
                    str=meta.spacedirections;
                    str(strfind(str, '(')) = ' ';
                    str(strfind(str, ')')) = ' ';
                    str(strfind(str, ',')) = ' ';
                    vs=sscanf(str, '%f');
                    
                    % THIS MIGHT NEED FIXING!
                    handles.voxel_size=[vs(1), vs(5), vs(9)]; % needed for export 
                    handles.image_coord_start=meta.spaceorigin; 
            end
 
            handles.PETimg= -handles.SUVmin/(handles.SUVmax-handles.SUVmin) +...
            handles.PETimgSUV/handles.SUVmax;
            handles.matsize=size(handles.PETimg);
            
            if handles.flagCT==1;
                ratio=size(handles.PETimg, 1)/size(handles.CTimg, 1);
                handles.CTimg = imresize(handles.CTimg, size(handles.PETimg, 1)/size(handles.CTimg, 1)); % resize CT img - halve in size
                
                axes=gca; % get current axes to resize them
                set(gca,{'xlim','ylim'}, {axes.YLim*ratio, axes.YLim*ratio})  % sets the zoom as it was 
            end
            handles.flagPET=1;
            
        case 'REFCONT'
            handles.loadtextCONT.String=file;
            [~, REF_name, ext]=fileparts(file);
            switch ext
                case '.am'
                    REFCONTdata=am2mat([path, file]);
                    handles.REFCONTimg=permute(REFCONTdata.data, [2, 1, 3]);
                case '.nrrd'
                    handles.REFCONTimg=nrrdread([path, file]);
            end
            
            handles.flagREFCONT=1;
            
        case 'SEGM'
            handles.loadtextCONT.String=file;
            [~, SEGM_name, ext]=fileparts(file);
            switch ext
                case '.am'
                    SEGMdata=am2mat([path, file]);
                    handles.SEGMimg=permute(SEGMdata.data, [2, 1, 3]);
                case '.nrrd'
                    handles.SEGMimg=nrrdread([path, file]);
            end
            
            handles.flagSEGM=1;
            
        otherwise
            disp('Wrong modality parameter.')
    end

    handles.console.String=['> Loaded ',modality,' ',file,'!'];
    drawnow
end


%% Plotter Function
% --- Executes whenever the image display needs refreshing.
function plotterfcn(~, handles)
 
    axes=gca; % get current axes in case of zoom
    xlim=axes.XLim;
    ylim=axes.YLim;
    
    if handles.flagCT==1; % plot PET image, if loaded.
        imshow(handles.CTimg(:,:,handles.slice), [handles.HUmin, handles.HUmax], 'InitialMag', 'fit');
    else    % plot blank sheet if not.
        imshow(zeros(handles.matsize(1), handles.matsize(2)), [handles.HUmin, handles.HUmax], 'InitialMag', 'fit');
    end

    hold on % add other images to CT background
    
    if handles.flagPET==1; % plot PET image
        %convert PET image into RGB map
        GrayIndex = uint8(floor(handles.PETimg(:,:,handles.slice) * 255));
        Map       = jet(255);
        RGB       = ind2rgb(GrayIndex, Map);

        % overlap PET, then apply alpha blending
        h = imshow(RGB);
        % set colormap transparency
        set(h, 'AlphaData', handles.PETimg(:,:,handles.slice));
    end
    % plot reference contours
    if handles.flagREFCONT==1 && max(max(handles.REFCONTimg(:,:,handles.slice))) > 0
        contour(handles.REFCONTimg(:,:,handles.slice)>0, [1,1], 'm', 'LineWidth',2);
    end
    % plot Segmentation contours
    if handles.flagSEGM==1 && max(max(handles.SEGMimg(:,:,handles.slice))) > 0
        contour(handles.SEGMimg(:,:,handles.slice)>0, [1,1], 'g', 'LineWidth',2);
    end
    % plot selected point
    if handles.flagPOINT==1 && handles.slice==handles.coord_Z
        scatter(handles.coord_X, handles.coord_Y, 100, [1,1,1], 'x')
    end
    % plot selected contour
    if handles.flagSELECT==1 && max(max(handles.SELECTimg(:,:,handles.slice))) > 0
        contour(handles.SELECTimg(:,:,handles.slice), [1,1], 'w', 'LineWidth',2);
    end
    % plot GANAR result
    if handles.flagGANAR==1 && max(max(handles.GANARimg(:,:,handles.slice))) > 0
        contour(handles.GANARimg(:,:,handles.slice), [1,1], 'y', 'LineWidth',2);
    end
    
    
    % if the previous plot was not blank, set the zoom as it was before
    if ~(isequal(xlim, [0,1]) && isequal(ylim, [0,1])) 
        zoom reset  % allows for zooming out later on
        set(gca,{'xlim','ylim'}, {xlim, ylim})  % sets the zoom as it was 
    end
    hold off;
    title(num2str(handles.slice));
end
function handles=sliceSelect_recalibration(hObject, handles)
% --- Called whenever a new dataset is loaded - checks number of slices.
    handles.sliceSelect.Max=handles.matsize(3);
    handles.sliceSelect.Min=1;
    handles.sliceSelect.SliderStep=[1/(handles.matsize(3)-1),20/(handles.matsize(3)-1)]; 
    
    % if current slice would fall outside provided data
    if handles.slice>handles.matsize(3) || handles.slice<1  
        handles.slice=ceil(handles.matsize(3)/2); % reset slice num
    end
    handles.sliceSelect.Value=handles.slice;    % properly position slider
    
    guidata(handles.figure1,handles);   % update handles in whole figure
    plotterfcn(hObject, handles) % replot
end


%% projection/permutation calllbacks
function projection_XY_Callback(hObject, ~, handles)
    handles.projection_XY.Value=1;
    if handles.projection_old==1;
        disp('No change')
    end
    if handles.projection_old==2;
        handles.console.String=['> Starting plane change ...'];
        drawnow
        handles.projection_XZ.Value=0;
        % permutation
        handles=permuteAll(hObject, handles, 'XZ->XY');
        handles.console.String=['> Display plane changed.'];
    end
    if handles.projection_old==3;
        handles.console.String=['> Starting plane change ...'];
        drawnow
        handles.projection_YZ.Value=0;
        % permutation
        handles=permuteAll(hObject, handles, 'YZ->XY');
        handles.console.String=['> Display plane changed.'];
    end
    handles.slice=handles.coord_Z;
    
    handles=sliceSelect_recalibration(hObject, handles);
    handles.projection_old=1;
    guidata(hObject, handles);
end
function projection_XZ_Callback(hObject, ~, handles)
    handles.projection_XZ.Value=1;
    if handles.projection_old==1;
        handles.console.String=['> Starting plane change ...'];
        drawnow
        handles.projection_XY.Value=0;
        % permutation
        handles=permuteAll(hObject, handles, 'XY->XZ');
        handles.console.String=['> Display plane changed.'];
    end
    if handles.projection_old==2;
        disp('No change')
    end
    if handles.projection_old==3;
        handles.console.String=['> Starting plane change ...'];
        drawnow
        handles.projection_YZ.Value=0;
        % permutation
        handles=permuteAll(hObject, handles, 'YZ->XZ');
        handles.console.String=['> Display plane changed.'];
    end
    handles.slice=handles.coord_Z;
    
    handles=sliceSelect_recalibration(hObject, handles);
    handles.projection_old=2;
    guidata(hObject, handles);
end
function projection_YZ_Callback(hObject, ~, handles)
    handles.projection_YZ.Value=1;
    if handles.projection_old==1;
        handles.console.String=['> Starting plane change ...'];
        drawnow
        handles.projection_XY.Value=0;
        % permutation
        handles=permuteAll(hObject, handles, 'XY->YZ');
        handles.console.String=['> Display plane changed.'];
    end
    if handles.projection_old==2;
        handles.console.String=['> Starting plane change ...'];
        drawnow
        handles.projection_XZ.Value=0;
        % permutation
        handles=permuteAll(hObject, handles, 'XZ->YZ');
        handles.console.String=['> Display plane changed.'];
    end
    if handles.projection_old==3;
        disp('No change')
    end
    handles.slice=handles.coord_Z;
    
    handles=sliceSelect_recalibration(hObject, handles);
    handles.projection_old=3;
    guidata(hObject, handles);
end


%% Window select functions
% --- Executes whenever image display parameters change.
function HUmin_Callback(hObject, ~, handles)
    % Sets the MIN HU window value, then replots image
    handles.HUmin=str2double(get(hObject,'String'));
    handles.console.String=['new HU min:', num2str(handles.HUmin)];
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function HUmax_Callback(hObject, ~, handles)
    % Sets the MAX HU window value, then replots image
    handles.HUmax=str2double(get(hObject,'String'));
    handles.console.String=['new HU max:', num2str(handles.HUmax)];
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function SUVminSet_Callback(hObject, ~, handles)
    % Sets the min SUV window value, recalculates plot PET then redraws
    handles.SUVmin=str2double(get(hObject,'String'));
    handles.PETimg= -handles.SUVmin/(handles.SUVmax-handles.SUVmin) +...
        handles.PETimgSUV/handles.SUVmax;
    handles.console.String=['new SUV min:', num2str(handles.SUVmin)];
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function SUVmaxSet_Callback(hObject, ~, handles)
    % Sets the max SUV window value, recalculates plot PET then redraws
    handles.SUVmax=str2double(get(hObject,'String'));
    handles.PETimg= -handles.SUVmin/(handles.SUVmax-handles.SUVmin) +...
        handles.PETimgSUV/handles.SUVmax;
    handles.console.String=['new SUV max:', num2str(handles.SUVmax)];
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function sliceSelect_Callback(hObject, ~, handles)
    % Sets selected slice to desired value, replots image
    handles.slice=int16(hObject.Value);
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end


%% Global contouring functions
% --- Executes on button press in contouring section.
function Contour_clear_Callback(hObject, ~, handles)
    % Erases current contours (if any) and creates a blank image to create
    % new contours on
    handles.SEGMimg=[];
    handles.flagSEGM=0;
    set(handles.console,'String','> Segmentation contour CLEARED!')
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function Contour_Load_Callback(hObject, ~, handles)
	% Loads an existing contour for further editing or analysis
%     [SEGM_in, path, filter] = uigetfile('*.am');
%     if SEGM_in==0
%         handles.console.String=['> No Segmentation selected!'];
%     else
%         handles.console.String=['> Loading ',path,SEGM_in,' ...'];
%         drawnow
%         % load and properly prepare the data, set image window
%         SEGMdata=am2mat([path, SEGM_in]);
%         handles.SEGMimg  =permute(SEGMdata.data, [2, 1, 3]);
%         handles.flagSEGM=1;
%         
%         plotterfcn(hObject, handles)
%         handles.console.String=['> Loaded ',path,SEGM_in,'!'];
%         guidata(handles.figure1,handles);
%     end
    
    % Select and load existing contour image
    [SEGM_in, SEGM_path, ~] = uigetfile([handles.filepath.String,'\*.am;*.nrrd']);
    if SEGM_in==0
        handles.console.String='> No CONTOUR image selected!';
    else
        % load reference contour data
        handles=LoadDataCall(handles, SEGM_path, SEGM_in, 'SEGM');
        % reset slider position, and redraw the figure
        handles=sliceSelect_recalibration(hObject, handles);
        
        % remember the last folder
        handles.filepath.String=SEGM_path;
    end
    
end
function threshold_SUV_Callback(hObject, ~, handles)
    % Sets new threshold value, then "clicks" generate button (see fcn below)
    set(handles.console,'String', ['> Threshold set to: ', num2str(hObject.String), ' SUV.'])
    handles.thresh_SUV=-handles.SUVmin/(handles.SUVmax-handles.SUVmin) + ...
        str2double(hObject.String)/handles.SUVmax;
    
    threshold_generate_Callback(hObject,1, handles)
end
function threshold_generate_Callback(hObject,~, handles)
	% Creates new mask based on threshold value, replots image
    if handles.flagPET==0;
        handles.console.String= ...
            ['> No PET image loaded! Load PET image and try again.'];
        return;
    end
    handles.SEGMimg=zeros(handles.matsize);
    handles.SEGMimg(handles.PETimg>handles.thresh_SUV)=1;
    handles.flagSEGM=1;
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function Contour_Save_Callback(hObject, ~, handles)
	% Saves current contour
    if handles.flagSEGM==0;
        handles.console.String= ['> Nothing to save.'];
        return
    end
    
    % properly orient seg for saving
    switch handles.projection_old
        case 1
            outIMG=handles.SEGMimg;
        case 2
            outIMG=permuteSingle(handles.SEGMimg, 'XZ->XY');
        case 3
            outIMG=permuteSingle(handles.SEGMimg, 'YZ->XY');
    end
    % save Contour
    [FileName,PathName] = uiputfile({'*.am';'*.nrrd'},...
        'Where to save contour? Select same format as input!', handles.filepath.String);
    [~, ~, ext]=fileparts(FileName);

    switch ext
        case '.am'
            outfile.data = permute(outIMG, [2, 1, 3]);
            outfile.voxel_size = handles.voxel_size;
            outfile.start = handles.image_coord_start;
            mat2am(outfile, [PathName, FileName]);
        case '.nrrd'
            pixelspacing = handles.voxel_size;
            origin = handles.image_coord_start;
            encoding ='raw'; % 'raw', 'ascii' or 'gzip'
            nrrdWriter([PathName, FileName], outIMG, pixelspacing, origin, encoding);
    end
    handles.console.String= ['> Segmentation saved.'];
    
end


%% Coordinate selection and movement
% note that in data selection X and Y coords are flipped!
function getXYZ_Callback(hObject, ~, handles)
    [x y] = ginput(1); % get crosshairs
    if x<0 || y<0 || x>handles.matsize(1) || y>handles.matsize(1)
       handles.console.String= ['> Select a voxel inside the image.'];
    else
        % save coord values
        handles.coord_X=int16(x);
        handles.coord_Y=int16(y);
        handles.coord_Z=handles.slice;
        
        % get single index of X
        handles.coordIDX=sub2ind(handles.matsize, handles.coord_Y,handles.coord_X,handles.coord_Z);
        handles.flagPOINT=1;
        
        % update XYZ numeric values in GUI
        handles.XYZ_X.String=num2str(handles.coord_X);
        handles.XYZ_Y.String=num2str(handles.coord_Y);
        handles.XYZ_Z.String=num2str(handles.slice);
        
        handles.console.String= ...
            ['> Voxel (',num2str(handles.coord_X),' ', num2str(handles.coord_Y),...
            ' ',num2str(handles.slice),') selected.'];
        % print info about voxel
        XYZ_data(handles)
    end
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function XYZ_X_Callback(hObject, ~, handles)
    % Move vox selection to given X coord
    handles.coord_X=uint16(str2num(handles.XYZ_X.String));
    handles.console.String= ['> New X coordinate: ', num2str(handles.coord_X)];
    handles.coordIDX=sub2ind(handles.matsize, handles.coord_Y,handles.coord_X,handles.coord_Z);
    handles.flagPOINT=1;
    
    % print info about voxel
    XYZ_data(handles)
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function XYZ_Y_Callback(hObject, ~, handles)
    % Move vox selection to given Y coord
    handles.coord_Y=uint16(str2num(handles.XYZ_Y.String));
    handles.console.String= ['> New Y coordinate: ', num2str(handles.coord_Y)];
    handles.coordIDX=sub2ind(handles.matsize, handles.coord_Y,handles.coord_X,handles.coord_Z);
    handles.flagPOINT=1;
    
    % print info about voxel
    XYZ_data(handles)
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function XYZ_Z_Callback(hObject, ~, handles)
    % Move vox selection and shown slice to given Z coord
    handles.coord_Z=uint16(str2num(handles.XYZ_Z.String));
    if handles.coord_Z<1 || handles.coord_Z>handles.matsize(3)
        handles.console.String= ['> Z should be [1,', num2str(handles.matsize(3)),']'];
        handles.flagPOINT=0;
    else
        handles.console.String= ['> New Z coordinate: ', num2str(handles.coord_Z)];
        handles.slice=handles.coord_Z;
        handles.sliceSelect.Value=handles.coord_Z;
        handles.coordIDX=sub2ind(handles.matsize, handles.coord_Y,handles.coord_X,handles.coord_Z);
        handles.flagPOINT=1;
        
        % print info about voxel
        XYZ_data(handles)
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    end
end
% keybinds for moving vox selection
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)

    switch eventdata.Key
        case 'rightarrow'
            handles.coord_X=handles.coord_X+1;
            handles.XYZ_X.String=num2str(handles.coord_X);
        case 'leftarrow'
            handles.coord_X=handles.coord_X-1;
            handles.XYZ_X.String=num2str(handles.coord_X);
        case 'uparrow'
            handles.coord_Y=handles.coord_Y-1;
            handles.XYZ_Y.String=num2str(handles.coord_Y);
        case 'downarrow'
            handles.coord_Y=handles.coord_Y+1;
            handles.XYZ_Y.String=num2str(handles.coord_Y);
        case 'pageup'
            handles.slice=handles.slice+1;
            handles.coord_Z=handles.slice;;
            handles.sliceSelect.Value=handles.slice;
            handles.XYZ_Z.String=num2str(handles.slice);
        case 'pagedown'
            handles.slice=handles.slice-1;
            handles.coord_Z=handles.slice;;
            handles.sliceSelect.Value=handles.slice;
            handles.XYZ_Z.String=num2str(handles.slice);
    end
    
    handles.coordIDX=sub2ind(handles.matsize, handles.coord_Y,handles.coord_X,handles.coord_Z);
    XYZ_data(handles)
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function XYZ_data(handles)
    % display selection coords...
    string1= ['> [',num2str(handles.coord_X),' ', ...
        num2str(handles.coord_Y),' ',num2str(handles.slice),']'];
    % ...CT number ...
    if handles.flagCT==1;
        string1=[string1, ' CT: ' num2str(handles.CTimg(handles.coord_Y, ...
            handles.coord_X,handles.coord_Z), '%2.0f')];
    end
    % ... any anything else present in the figure.
    if handles.flagPET==1;
        string1=[string1, ' PET: ' num2str(handles.PETimgSUV(handles.coord_Y, ...
            handles.coord_X,handles.coord_Z), '%0.2f')];
    end
    if handles.flagREFCONT==1;
        string1=[string1, ' REF: ' num2str(handles.REFCONTimg(handles.coord_Y, ...
            handles.coord_X,handles.coord_Z))];
    end
    if handles.flagSEGM==1;
        string1=[string1, ' SEGM: ' num2str(handles.SEGMimg(handles.coord_Y, ...
            handles.coord_X,handles.coord_Z))];
    end
    if handles.flagGANAR==1;
        string1=[string1, ' GANAR: ' num2str(handles.GANARimg(handles.coord_Y, ...
            handles.coord_X,handles.coord_Z))];
    end
    handles.console.String=string1;
end


%% Single contour tools
function Contour_select_Callback(hObject, ~, handles)
    % this function selects the single contour that contains the voxel
    % pointer (X)
    if handles.flagPOINT==0
        handles.console.String= ['> No pointer placed!'];
        return
    end
    if handles.flagSEGM==0
        handles.console.String= ['> No active contours!'];
        return
    end
    % if the coords provided are within a contour, select it
    if handles.SEGMimg(handles.coordIDX)>0
        handles.console.String= ['> Selecting area containing voxel [', ...
            num2str(handles.coord_X),' ', num2str(handles.coord_Y),' ',...
            num2str(handles.coord_Z),'] ...'];
        drawnow
        % call the function doing the actual selecting
        handles.SELECTimg= select_volume_from_point(handles.coordIDX, handles.SEGMimg);
        handles.flagSELECT=1;
        handles.console.String= ['> Contour selected.'];
        
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> Voxel [', num2str(handles.coord_X),' ',...
        num2str(handles.coord_Y),' ',num2str(handles.coord_Z),...
        '] not in a segmented contour!'];
    end
end
function Contour_deselect_Callback(hObject, ~, handles)
    % clears current selection
    handles.SELECTimg(:)=0;
    handles.flagSELECT=0;
    
    handles.console.String= ['> Volume deselected.'];
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function Contour_grow_new_Callback(hObject, ~, handles)
    % selects a single contour, based in PET image, pointer and local
    % threshold
    if handles.flagPOINT==0;
        handles.console.String = ['> No pointer placed!'];
        return
    end
    
    % if the coords provided are already within a contour
    if handles.PETimgSUV(handles.coordIDX)>handles.thresh_grow_SUV
        handles.console.String= ['> Selecting area containing voxel [', ...
            num2str(handles.coord_X),' ', num2str(handles.coord_Y),' ',...
            num2str(handles.coord_Z),'] ...'];
        drawnow

        mask=zeros(handles.matsize);
        % create global thresholded contours
        mask(handles.PETimgSUV>handles.thresh_grow_SUV)=1;
        % select only the one with voxel pointer
        handles.SELECTimg=select_volume_from_point(handles.coordIDX, mask);
        
        handles.flagSELECT=1;
        handles.console.String= ['> Contour grown.'];
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> Selected voxel has a value ', ...
            num2str(handles.PETimgSUV(handles.coord_Y,handles.coord_X,handles.coord_Z))...
            ' SUV which is below threshold!'];
    end
end
function Threshold_grow_Callback(hObject, ~, handles)
    % resets the grow threshold
    handles.console.String=['> Threshold set to: ', num2str(hObject.String), ' SUV.'];
    
    handles.thresh_grow_SUV= str2double(hObject.String);
    handles.thresh_grow=-handles.SUVmin/(handles.SUVmax-handles.SUVmin) + ...
        str2double(hObject.String)/handles.SUVmax;
    if handles.flagSELECT==1;
        handles.console.String=[handles.console.String,' Resizing contour.'];
        % See fcn Contour_grow_new_Callback
        mask=zeros(handles.matsize);
        mask(handles.PETimgSUV>handles.thresh_grow_SUV)=1;
        handles.SELECTimg=select_volume_from_point(handles.coordIDX, mask);
        handles.flagSELECT=1;
        
        handles.console.String= ['> Contour resized.'];
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    end
    guidata(hObject,handles);
    handles.console.String=['> Threshold2 set to: ', num2str(handles.thresh_grow_SUV), ' SUV.'];
end
function Contour_dilate_Callback(hObject, ~, handles)
    % grow 1 voxel all around a selected contour
    if handles.flagSELECT==1;
        handles.console.String= ['> Dilating contour ...'];
        drawnow
        
        dilution=ones(3, 3, 3); % define dilution matrix - a cube
        se = strel('arbitrary', dilution);
        handles.SELECTimg=imdilate(handles.SELECTimg, se);
        
        handles.console.String= ['> Contour dilated. New size: ', num2str(sum(handles.SELECTimg(:)))];
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> No contour selected!'];
    end
end
function Contour_erode_Callback(hObject, ~, handles)
    % eat away 1 voxel from selected contour
    if handles.flagSELECT==1;
        handles.console.String= ['> Eroding contour ...'];
        drawnow
        
        dilution=ones(3, 3, 3); % define dilution matrix - a cube
        se = strel('arbitrary', dilution);
        handles.SELECTimg=imerode(handles.SELECTimg, se);
        
        handles.console.String= ['> Contour eroded. New size: ', num2str(sum(handles.SELECTimg(:)))];
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> No contour selected!'];
    end
end
function Contour_freehand_Callback(hObject, ~, handles)
    h = [] ;
%     h = imfreehand(gca);
    h = imfreehand();
    
    handles.SELECTimg=zeros(size(handles.PETimg));
    
    handles.SELECTimg(:,:,handles.slice) = createMask(h, handles.figure1.CurrentObject);
    handles.flagSELECT=1;
    delete(h)
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function Contour_add_Callback(hObject, ~, handles)
    % if the coords provided are within a contour, add the volume to SEGM
    if handles.flagSEGM==0;
        % make blank SEGM image, if none loaded
        handles.SEGMimg=zeros(handles.matsize);
        handles.flagSEGM=1;
    end
    if handles.SELECTimg(handles.coord_Y, handles.coord_X, handles.coord_Z)==1
        handles.console.String= ['> Adding selected volume ...'];
        drawnow
        % add the contour to original mask
        handles.SEGMimg(handles.SELECTimg==1)=1;
        handles.console.String= ['> Volume added.'];
        
        handles.SELECTimg(:)=0;
        handles.flagSELECT=0;
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> No volume selected!'];
    end
end
function Contour_remove_Callback(hObject, ~, handles)
    % if the coords provided are within a contour, remove the volume
    if sum(handles.SELECTimg(:))>0
        handles.console.String= ['> Removing selected volume ...'];
        drawnow
        
        % get the mask of selected contour only
        handles.SEGMimg(handles.SELECTimg>0)=0;   % delete the contour on original mask
        handles.console.String= ['> Volume removed.'];
        
        handles.SELECTimg(:)=0;
        handles.flagSELECT=0;
        
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> No volume selected!'];
    end
end


%% Fancy tools
function Call_Threshold_optimization_Callback(hObject, ~, handles)
    % using reference contours as golden standard, finds optimal threshold
    % for each lesion marked. 
    if handles.flagREFCONT==0;
        handles.console.String= ['> No reference contours loaded!'];
    else
        handles.console.String= ['> Searching for optimal thresholds ...'];
        drawnow
        
        % call the actual function
        handles.SEGMimg=Get_opt_thresh(handles.PETimgSUV, handles.REFCONTimg);
        
        handles.flagSEGM=1;
        handles.console.String= ['> Search for optimal threshold completed.'];
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    end
end
function Call_GANAR_Callback(hObject, ~, handles)

    handles.console.String= ['> GANAR disabled for this project submission. Please provide get the DLC for just 99.99$ or final grade A for a season pass*.'];
    % *this statement may or may not be accurate.
    return

    % start GANAR on a lesion, with SELECT contour as a mask
    % check function viability
    if handles.flagSELECT==0;
        handles.console.String= ['> No contour selected!'];
        return
    end
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    
    % prep for file saving
    [FileName,PathName] = uiputfile({'*.am';'*.nrrd'},'Select GANAR output', handles.filepath.String);
    
    % run GANAR
    [Gstruct,handles.GANARimg] = GANAR(handles.PETimg, handles.SELECTimg);
    handles.flagGANAR=1;
    handles.console.String= ['> GANAR completed.'];
    
    % properly orient the mask for saving
    switch handles.projection_old
        case 1
            outIMG=handles.GANARimg;
        case 2
            outIMG=permuteSingle(handles.GANARimg, 'XZ->XY');
        case 3
            outIMG=permuteSingle(handles.GANARimg, 'YZ->XY');
    end
    % save GANAR output
    [~, ~, ext]=fileparts(FileName);
    switch ext
        case '.am'
            outfile.data = permute(outIMG, [2, 1, 3]);
            outfile.voxel_size = handles.voxel_size;
            outfile.start = handles.image_coord_start;
            mat2am(outfile, [PathName, FileName]);
        case '.nrrd'
            pixelspacing = handles.voxel_size;
            origin = handles.image_coord_start;
            encoding ='raw'; % 'raw', 'ascii' or 'gzip'
            nrrdWriter([PathName, FileName], outIMG, pixelspacing, origin, encoding);
    end
    handles.console.String= ['> Segmentation saved.'];
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function GetStats_Callback(hObject, eventdata, handles)
    if handles.flagSEGM==0
        handles.console.String= ['> No active contours!'];
        return
    end
    [FileName,PathName] = uiputfile([handles.filepath.String, '\*.mat'],'Create output file ');
    [~, out_name, ~]=fileparts(FileName);
    
    stats=LesStats_GUI(handles.PETimg,handles.SEGMimg);
    
    eval([out_name '= stats;']);
    eval(['save([PathName, FileName], ''',out_name,''');']);
    
    disp(1)
end
function Call_Segmentation_comparison_Callback(hObject, ~, handles)
    % one button calculation of quick statistic for comparing SEGM contours
    % with REFCONT. 
    if handles.flagSEGM==0;
        handles.console.String= ['> No segmentation in image!'];
    elseif handles.flagREFCONT==0;
        handles.console.String= ['> No reference contours loaded!'];
    else
        handles.console.String= ['> Starting segmentation comparison ...'];
        drawnow
        % outputs a whole bunch of useful lesion stats. Save struct 
        % fix to save Matched_data if you preffered the results are not lost.
        Matched_data=Compare_segmentations(handles.SEGMimg, handles.REFCONTimg);
        
        % match N, SEGM N, REF N, match V, segm V, ref V, Wmean DICE, mean OV
        a=Matched_data.Match_global;
        
        % print summary of analysis
        handles.console.String= ['> ', num2str(a(1)), ' matched, ', ...
            num2str(size(Matched_data.SEGMonly, 1)), ' SEGM + '...
            , num2str(size(Matched_data.REFonly, 1)), ' REF unmatched. WMean DICE: ', ...
            num2str(a(7)), ' Mean DICE: ', num2str(a(8)) ];
        disp(['params: ',num2str(a(1)),' ', num2str(size(Matched_data.SEGMonly, 1)),' ', ...
            num2str(size(Matched_data.REFonly, 1)),' ', num2str(a(7)),' ', num2str(a(8))])
    end
end

function watershed_2D_Callback(hObject, ~, handles)
    % calls a gradient segmentation method
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    handles.console.String= ['> Starting 2D watershed segmentation ...'];
    drawnow

    handles.SEGMimg = watershed_2D(handles.PETimgSUV);
    handles.flagSEGM=1;
    
    handles.console.String= ['> Completed 2D watershed segmentation.'];
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
    
end
function Watershed_25D_Callback(hObject, eventdata, handles)
    % calls a gradient segmentation method
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    handles.console.String= ['> Starting 2.5D watershed segmentation ...'];
    drawnow

    handles.SEGMimg = watershed_25D(handles.PETimgSUV);
    handles.flagSEGM=1;
    
    handles.console.String= ['> Completed 2.5D watershed segmentation.'];
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)

end
function watershed_2D_marks_Callback(hObject, eventdata, handles)
    % calls a gradient segmentation method
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    
%     [MARK_in, MARK_path, ~] = uigetfile('*.am');
    MARK_in='1001B_B1_MAXmarkers.am';
    MARK_path='E:\010-work\1001B\B1\Processed';
    if MARK_in==0
        handles.console.String='> No MARK image selected!';
        return
    else
        handles.console.String= ['> Loading ...'];
        drawnow
        in_MARK=am2mat([MARK_path, '\', MARK_in]);
        MARK_img=permute(in_MARK.data, [2, 1, 3]);
    end

    handles.console.String= ['> Starting 2D watershed segmentation from markers ...'];
    drawnow
    
    appxIMG=markers_appximate(handles.PETimgSUV, MARK_img);
    handles.SEGMimg = markers_watershed_2D(handles.PETimgSUV, appxIMG);
    handles.flagSEGM=1;
    
    handles.console.String= ['> Completed 2D watershed segmentation from markers.'];
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)

end
function watershed_25D_marks_Callback(hObject, eventdata, handles)
    % calls a gradient segmentation method
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    
%     [MARK_in, MARK_path, ~] = uigetfile('*.am');
    MARK_in='1001B_B1_MAXmarkers.am';
    MARK_path='E:\010-work\1001B\B1\Processed';
    if MARK_in==0
        handles.console.String='> No MARK image selected!';
        return
    else
        handles.console.String= ['> Loading ...'];
        drawnow
        in_MARK=am2mat([MARK_path, '\', MARK_in]);
        MARK_img=permute(in_MARK.data, [2, 1, 3]);
    end

    handles.console.String= ['> Starting 2.5D watershed segmentation from markers ...'];
    drawnow
    
    appxIMG=markers_appximate(handles.PETimgSUV, MARK_img);
    handles.SEGMimg = markers_watershed_25D(handles.PETimgSUV, appxIMG);
    handles.flagSEGM=1;
    
    handles.console.String= ['> Completed 2.5D watershed segmentation from markers.'];
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end


%% Work in progress
function gc_segm_Callback(hObject, ~, handles)
    % calls a graph cut segmentation method
    
    % Do we have all the data?
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    if handles.flagCT==0;
        handles.console.String= ['> No CT image loaded!'];
        return
    end
    if handles.flagSELECT==0;
        handles.console.String= ['> No volume selected!'];
        return
    end
    
    handles.console.String= ['> Selecting image crop ...'];
    drawnow

    %% push the data to the segmentation function
    % get coordinates of all the voxels in the interest, get min/max
    [y, x, z]=ind2sub(size(handles.SELECTimg), find(handles.SELECTimg>0));

    % figure out crop borders
    CTcrop=handles.CTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    PETcrop=handles.PETimgSUV(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    SELECTcrop=handles.SELECTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    
    % call the segmentation and crop result to initially selected volume
    out=gc_segm(CTcrop, PETcrop, SELECTcrop);
    out= out .* handles.SELECTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    
    
    if handles.flagSEGM==0;
        handles.SEGMimg=zeros(size(handles.PETimg));
        handles.flagSEGM=1;
    end
    handles.SEGMimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1)= out;
    
    handles.console.String= ['> Graph cut completed.'];
    guidata(hObject,handles);
    plotterfcn(hObject, handles)

    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function GC25D_Callback(hObject, ~, handles)
    % calls a graph cut segmentation method
    
    %% Do we have all the data?
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    if handles.flagCT==0;
        handles.console.String= ['> No CT image loaded!'];
        return
    end
    if handles.flagSELECT==0;
        handles.console.String= ['> No volume selected!'];
        return
    end
    
    handles.console.String= ['> Selecting image crop ...'];
    drawnow

    %% push the data to the segmentation function
    % get coordinates of all the voxels in the interest, get min/max
    [y, x, z]=ind2sub(size(handles.SELECTimg), find(handles.SELECTimg>0));

    % figure out crop borders
    CTcrop=handles.CTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    PETcrop=handles.PETimgSUV(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    SELECTcrop=handles.SELECTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    
    % call the segmentation and crop result to initially selected volume
    out=gc_segm25d(CTcrop, PETcrop, SELECTcrop);
    out= out .* handles.SELECTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
    
    
    if handles.flagSEGM==0;
        handles.SEGMimg=zeros(size(handles.PETimg));
        handles.flagSEGM=1;
    end
    handles.SEGMimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1)= out;
    
    handles.console.String= ['> Graph cut completed.'];

    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end

function all_gc_Callback(hObject, ~, handles)
% Do we have all the data?
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    if handles.flagCT==0;
        handles.console.String= ['> No CT image loaded!'];
        return
    end
    if handles.flagREFCONT==0;
        handles.console.String= ['> No REFerence image loaded!'];
        return
    end

    
    reflist=unique(handles.REFCONTimg); % find all ref contours  
    reflist=reflist(reflist>0);   % except 0, which is the background
    handles.flagSELECT=1;  % show plotting of select, if not done yet

    handles.SEGMimg=zeros(size(handles.PETimg));
    handles.flagSEGM=1;

    
    for i= 1:length(reflist)
        lesnum=reflist(i);
        disp(lesnum)
        handles.SELECTimg=double(handles.REFCONTimg==lesnum);
        
        
        % dilate the selection twice to get something reasonable
        dilation=ones(3, 3, 3); % define dilution matrix - a cube
        se = strel('arbitrary', dilation);
        handles.SELECTimg=imdilate(handles.SELECTimg, se);
        handles.SELECTimg=imdilate(handles.SELECTimg, se);
        % redraw
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
        
        %% push the data to the segmentation function
        % get coordinates of all the voxels in the interest, get min/max
        [y, x, z]=ind2sub(size(handles.SELECTimg), find(handles.SELECTimg>0));

        % figure out crop borders
        CTcrop=handles.CTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
        PETcrop=handles.PETimgSUV(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
        SELECTcrop=handles.SELECTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);

        % call the segmentation and crop result to initially selected volume
        out=gc_segm25d(CTcrop, PETcrop, SELECTcrop);
        
        %% do shenanigans to not erase other contours inside ROI
        % we're just changing contours inside ROI
        out= out .* handles.SELECTimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
        
        % get copy of current SEGM ROI in case there is anything there
        temp=handles.SEGMimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1);
        temp=temp+out; % combine the images. This will break somewhat if contours actually overlap.
        
        handles.SEGMimg(min(y)-1:max(y)+1,min(x)-1:max(x)+1,min(z)-1:max(z)+1)=temp;
        % redraw
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    end
    
    
    
end

function neighbour_Callback(hObject, ~, handles)
    indeces=find(handles.SELECTimg>0);
%     neigh=find_mat_neighbours(handles.coordIDX, handles.matsize);
    neigh=find_mat_neighbours(indeces, handles.matsize);
    
    new=zeros(handles.matsize);
    new(neigh)=1;
    
    handles.SELECTimg=new;
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end
function watershed_3D_Callback(hObject, ~, handles)
    % calls a gradient segmentation method. Work in progress.
    if handles.flagPET==0;
        handles.console.String= ['> No PET image loaded!'];
        return
    end
    handles.console.String= ['> Starting 3D watershed segmentation ...'];
    drawnow

    handles.SEGMimg = watershed_3D(handles.PETimgSUV);
    handles.flagSEGM=1;
    
    handles.console.String= ['> Completed 3D watershed segmentation.'];
    
    % mark end of calculation
    load handel
    sound(y(1:34000),Fs)
    
    guidata(hObject,handles);
    plotterfcn(hObject, handles)
end

function create_crop_Callback(hObject, eventdata, handles)
    % exports a selected subvolume of the image
    
    if handles.flagSELECT==1;
        handles.console.String= ['> Exporting image crop ...'];
        drawnow
        
        
        %% get coordinates of all the voxels in the interest, get min/max
        [y, x, z]=ind2sub(size(handles.SELECTimg), find(handles.SELECTimg>0));
        
        
        %% save CT crop
        outImg=handles.CTimg(min(y):max(y),min(x):max(x),min(z):max(z));
        [FileName,PathName] = uiputfile({'*.am';'*.nrrd'},...
        'Where to save CT contour? Select same format as input!', handles.filepath.String);
        [~, ~, ext]=fileparts(FileName);
        switch ext
        case '.am'
            outfile.data = permute(outImg, [2, 1, 3]);
            outfile.voxel_size = handles.voxel_size;
            outfile.start = handles.image_coord_start;
            mat2am(outfile, [PathName, FileName]);
        case '.nrrd'
            pixelspacing = handles.voxel_size;
            origin = handles.image_coord_start;
            encoding ='raw'; % 'raw', 'ascii' or 'gzip'
            nrrdWriter([PathName, FileName], outImg, pixelspacing, origin, encoding);
        end
        
        %% save PET crop
        outImg=handles.PETimgSUV(min(y):max(y),min(x):max(x),min(z):max(z));
        [FileName,PathName] = uiputfile({'*.am';'*.nrrd'},...
        'Where to save PET contour? Select same format as input!', handles.filepath.String);
        [~, ~, ext]=fileparts(FileName);
        switch ext
        case '.am'
            outfile.data = permute(outImg, [2, 1, 3]);
            outfile.voxel_size = handles.voxel_size;
            outfile.start = handles.image_coord_start;
            mat2am(outfile, [PathName, FileName]);
        case '.nrrd'
            pixelspacing = handles.voxel_size;
            origin = handles.image_coord_start;
            encoding ='raw'; % 'raw', 'ascii' or 'gzip'
            nrrdWriter([PathName, FileName], outImg, pixelspacing, origin, encoding);
        end
        
        handles.console.String= ['> Cropped data exported.'];
        guidata(hObject,handles);
        plotterfcn(hObject, handles)
    else
    % if not, just send out a notification.
        handles.console.String= ['> No contour selected!'];
    end
    
end

%% Create functions
% --- Executes during object creation, after setting all properties.
% Don't really need them usually.
