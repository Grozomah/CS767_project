function C=matching(SEGM,REF)
% MATCHING Support function for comparing segmentations
%   C=matching(SEGM,REF) finds overlap between segmentations and outputs a
%   struct containing information about contours.
%
%   Matched_data.Match:
%       Segm #, REF #, DICE, OV, OVseg, intersect V, SEGM V, REF V
%   Matched_data.Match_global:
%       match N, SEGM N, REF N, match V, segm V, ref V, Wmean DICE, mean DICE
%   Matched_data.REFonly:
%       REF #, Volume
%   Matched_data.SEGMonly:
%       SEGM #, Volume
%   Created by PF 6/?/2016

Match=[];   % Segm #, REF #, DICE, OV, OVseg, intersect V, SEGM V, REF V
SEGMonly=[];% SEGM #, SEGM V
REFonly=[]; % REF #, REF V
Match_global=[];
% match N, SEGM N, REF N, match V, segm V, ref V, Wmean DICE, mean DICE

SEGM = double(SEGM);
REF = double(REF);

%% Get matched lesion stats
REFlesions = unique(REF(REF>0));
h = waitbar(0,'Matching');

for i=1:length(REFlesions)
    waitbar(i/length(REFlesions), h)
    REF_mask = find(REF==REFlesions(i)); %get current REF lesion indexes
    
    SEGMlesions = unique(SEGM(REF_mask));
    SEGMlesions = SEGMlesions(SEGMlesions>0);
    
    if size(SEGMlesions,1)>0 
        %calculate the overlap.
        for j=1:length(SEGMlesions)
            SEGM_mask = find(SEGM==SEGMlesions(j)); % get current SEGM lesion indexes

            % get union and intersect volumes
            vol_union = SEGM_mask;
            vol_union = unique([vol_union; REF_mask]);
            vol_intersect = intersect(SEGM_mask, REF_mask);
            
            % get some lesion stats
            N_union = length(vol_union);
            N_intersect = length(vol_intersect);
            N_SEGM = length(SEGM_mask);
            N_REF = length(REF_mask);
            
            DICE_val = 100.0*(2*N_intersect/(N_SEGM + N_REF));
            OV = 100.0*(N_intersect/min(N_SEGM,N_REF));
            OVseg = 100.0*(N_intersect/N_SEGM);
            
            % Segm #, REF #, DICE, OV, OVseg, intersect V, SEGM V, REF V
            Match=[Match;SEGMlesions(j), REFlesions(i), DICE_val, OV, OVseg, N_intersect, N_SEGM, N_REF];
        end
    end
end


%% Get SEGMonly lesion stats
SEGMlesions = unique(SEGM(SEGM>0));
SEGMonlyLes = SEGMlesions(~ismember(SEGMlesions, Match(:,1)));
waitbar(0, h, 'SEGM only lesions')
for i=1:length(SEGMonlyLes)
    waitbar(i/length(SEGMonlyLes), h)
    n=SEGMonlyLes(i);
    
    SEGMonly=[SEGMonly; n, sum(SEGM(:)==n)];
end

%% Get REFonly lesion stats
REFlesions = unique(REF(REF>0));
REFonlyLes = REFlesions(~ismember(REFlesions, Match(:,2)));
waitbar(0, h, 'REF only lesions')
for i=1:length(REFonlyLes)
    waitbar(i/length(REFonlyLes), h)
    n=REFonlyLes(i);
    REFonly=[REFonly; n, sum(REF(:)==n)];
end

%% get global matching stats
Match_global=[
    size(Match, 1), length(SEGMlesions), length(REFlesions),...
    sum(Match(:,6)), sum(SEGM(:)>0), sum(REF(:)>0), ...
    sum(Match(:,3).*Match(:,6))/sum(Match(:,6)), mean(Match(:,3))];
% match N, SEGM N, REF N, match V, segm V, ref V, Wmean DICE, mean DICE
    
    
%% Set up output
C.Match=Match;
C.SEGMonly=SEGMonly;
C.REFonly=REFonly;
C.Match_global=Match_global;

%% Do last check if the number of lesions match, cleanup
if size(SEGMonly)~=[0,0]
    if length(unique(Match(:,1)))+length(unique(SEGMonly(:,1)))~= length(SEGMlesions)
    warning('Something is buggy');
end
end
if size(REFonly)~=[0,0]
    if length(unique(Match(:,2)))+length(unique(REFonly(:,1)))~= length(REFlesions)
    warning('Something is buggy');
    end
end

close(h) 
end


