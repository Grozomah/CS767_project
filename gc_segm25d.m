function segmIMG=gc_segm25d(CTcrop, PETcrop, SELECTcrop);
% perform 2.5 dimensional segmentation using graph cuts and majority
% voting.
% Is basically a wrapper for three gc_segm functions
    
    % first projection
    out1=gc_segm(CTcrop, PETcrop, SELECTcrop);

    % second projection
    CTcrop2=flipud(permute(CTcrop, [3,2,1]));
    PETcrop2=flipud(permute(PETcrop, [3,2,1]));
    SELECTcrop2=flipud(permute(SELECTcrop, [3,2,1]));
    
    out2=gc_segm(CTcrop2, PETcrop2, SELECTcrop2);
    out2=permute(flipud(out2), [3,2,1]);

    % third projection
    CTcrop3=flipud(permute(flipud(CTcrop), [3,1,2]));
    PETcrop3=flipud(permute(flipud(PETcrop), [3,1,2]));
    SELECTcrop3=flipud(permute(flipud(SELECTcrop), [3,1,2]));
    
    out3=gc_segm(CTcrop3, PETcrop3, SELECTcrop3);
    out3=flipud(permute(flipud(out3), [2,3,1]));
    
    %% combining the 2D segmentations
    Sseg=out1+out2+out3;
    segmIMG=zeros(size(PETcrop));
%     out=smooth_matx_3D(Sseg);
    Sseg = smooth3(Sseg,'box',3);
    
    segmIMG(Sseg>1.7)=1;
    
    se = strel(ones(2,2,2));
    segmIMG=imclose(segmIMG, se); % small fix
    disp('Graph cut 2.5D completed')

end
