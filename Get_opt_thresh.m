function SEGMimg=Get_opt_thresh(PETimg, REFCONTimg)
% GET OPTIMAL THRESHOLDS  threshold analysis function.
%   SEGMimg=Get_opt_thresh(PETimg, REFCONTimg) goes through all the lesions
%   in REFCONT, and for each finds the optimal fixed value threshold.
%   Returns this optimal mask and outputs a parameter table 'alldata' into
%   current workspace.
% 
%   PETimg - 3D PET image
%   REFCONTimg - 3D reference contour image
%   SEGMimg - 3D binary mask
%
%   Created by PF 6/?/2016
    
    % outputs (table): Les#, Thr, DICE, Vol, Max
    clc
    %% params
    dt=0.25;   % threshold step value
            
    %% begin program
    
    REF = int16(bwlabeln(REFCONTimg,26)); % get all lesions, number them
    REFlesions=unique(REF(REF>0));      %  get all lesion numbers
    
    alldata=[];
    allMask=zeros(size(PETimg));
    h = waitbar(0,'Matching');
    
    for i=1:length(REFlesions)
        n=REFlesions(i);    % assigned lesion number. Probably =i.
        lmask= (REF==n);       % Get reference lesion mask
        ldata=PETimg.*(REF==n);   % extract lesion values
        Nlmask=sum(lmask(:));
        
        [maxVal maxidx] = max(ldata(:));
        tmask=zeros(size(PETimg));
        
        disp('Starting search for threshold')
        
        optThresh=99;
        optThreshVal=0;
        

        for threshold= 3 : dt: 15
            % find tumor mask for given threshold
            if threshold>maxVal % threshold higher than local max
                allMask=allMask + OptiMask;
                break
            end
            tmask=PETimg>threshold;
            tmask=select_volume_from_point(maxidx, tmask);
            Ntmask=sum(tmask(:));
            % calculate overlap & DICE coefficient
            overlap=tmask.*lmask;
            Noverlap=sum(overlap(:));
            DICE=(2* Noverlap)/(Nlmask+Ntmask);
            
            disp(['lesion: ', num2str(i),', thr: ', num2str(threshold, '%0.2f'),...
                ', DICE: ',num2str(DICE, '%0.3f')])
            
            % have we found a new optimum?
            if DICE>optThreshVal
                optThresh=threshold;
                optThreshVal=DICE;
                OptiMask=tmask;
            elseif DICE < optThreshVal-0.3 %are we far away from an existing opt?
%                 disp('moving away from opt')
                    allMask=allMask + OptiMask;
                break
            end

        end
        % save the data
        singledata=[i, optThresh, optThreshVal, Ntmask, maxVal]; 
        alldata=[alldata; singledata];
        allMask = allMask + i*OptiMask;
        
        disp('')
        disp(' > End results: Les#, Thr, DICE, Vol, Max')
        disp([singledata])
        fprintf('\n')
        waitbar(i/length(REFlesions), h)
    end

    assignin('base', 'alldata', alldata)
    assignin('base', 'OptiMask', OptiMask)
    SEGMimg=allMask;
    
    close(h)
end
