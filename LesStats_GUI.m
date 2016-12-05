function stats=LesStats_GUI(PETimg, SEGMimg)
    % This function calculates lesion stats for selected segmentation and
    % returns them as stats.

    % Created by: PF 7/7/2016
    
    % stats output: # of lesions, vol, max, mean, std
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CC = bwconncomp(SEGMimg>0, 6);
    LesMask = labelmatrix(CC);
    
    LesList=unique(LesMask);
    LesList=LesList(LesList>0);
    
    outAll=[];
    for i=transpose(LesList)
        idx=find(LesMask==i);
        out=[i, length(idx), max(PETimg(idx)), mean(PETimg(idx)), std(PETimg(idx))];
        
        outAll=[outAll; out];
    end
    
    stats.all=outAll;
    stats.global=[mean(outAll(:,2)), mean(outAll(:,3)), mean(outAll(:,4)), mean(outAll(:,5))];
end