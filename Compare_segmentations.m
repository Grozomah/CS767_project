function Matched_data=Compare_segmentations(SEGMimg, REFCONTimg)
% COMPARE SEGMENTATIONS  Compare created contours to reference.
%   Matched_data=Compare_segmentations(SEGMimg, REFCONTimg) performs the
%   comparison between two masks and returns the matched data
%
%   Matched_data.Match contents:
%       Segm #, REF #, DICE, OV, OVseg, intersect V, SEGM V, REF V
%   Matched_data.Match_global contents:
%       match N, SEGM N, REF N, match V, segm V, ref V, Wmean DICE, mean DICE
%   Matched_data.REFonly:
%       REF #, Volume
%   Matched_data.SEGMonly:
%       SEGM #, Volume
%   Created by PF 6/?/2016

    
    if size(SEGMimg) ~= size(REFCONTimg)
       error('Segmentation sizes do not match!')
    end
    
    %% lesion identification
    data.segm = int16(bwlabeln(SEGMimg,26));
    data.ref = int16(bwlabeln(REFCONTimg,26));
    
    %% lesion matching
    Matched_data=matching_GUI(data.segm, data.ref);
    % Segm #, REF #, DICE, OV, OVseg, intersect V, SEGM V, REF V
    % match N, SEGM N, REF N, match V, segm V, ref V, Wmean DICE, mean DICE
    
%     disp('1')
%     assignin('base', 'Matched_data_Fixed', Matched_data)
end