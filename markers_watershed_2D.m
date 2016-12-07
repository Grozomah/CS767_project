function segmIMG=markers_watershed_2D(petIMG, appxIMG)
% 2D WATERSHED SEGMENTATION FROM MARKERS 
%   segmIMG=markers_watershed_2D(petIMG, appxIMG)
%   An improvement on 2D watershed segmentation, this function takes user
%   defined approximate image markers as foreground objects.
%
%   see also: watershed_2D
%   
%   Created by PF 7/5/2016

%% tweak parameters
% thfgm=9; % foreground markers threshold: Naf: 9, FDG: 15e3
thbgm=0.1e0; % background markers threshold: 0.1
% thsegm=8; % final decision threshold: Naf: 8


%% no touchy fishy after here.
% ( http://i.imgur.com/ZigXHzX.gifv )

%% watershed the created approximations.
h=waitbar(0, 'Watershed 2D');
for sliceN= 1:size(petIMG,3)
    
    waitbar(sliceN/size(petIMG,3))
    I=petIMG(:,:,sliceN);
    
    if max(I(:))<7  % ignore low SUV slices
       segmIMG0(:,:,sliceN)=zeros(size(I));
       continue
    end
    
    %% step 2 / calculate raw gradient image
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);


    %% define foreground markers - lesion seeds
    se2 = strel(ones(2,2));
    fgm = appxIMG(:,:,sliceN);   % define foreground mask

    %% define background markers
    bgm=imclose(petIMG(:,:,sliceN)<thbgm, se2);

    %% Step 5: Compute the Watershed Transform of the Segmentation Function.
    % impose minimum on objects definitely inside and def outside
    
    gradmag2 = imimposemin(gradmag, bgm | fgm);    
%     imshow(gradmag2, [0, 10])
    L = watershed(gradmag2);
%     imshow(L, [0,max(L(:))])
    
    if sliceN==249
        disp(1)
    end

    %% output data prep
    outI=zeros(size(I));
    for i=min(L(:)):max(L(:))
        if sum(fgm(L==i))/sum(L(:)==i)>0.2
            outI(L==i)=1;
        end
    end
    segmIMG0(:,:,sliceN)=outI;
end
%     se3 = strel('disk', 1);
    se3 = strel('ball', 1,1, 0);
    segmIMG2=imdilate(segmIMG0, se3)-1;

    CC=bwconncomp(segmIMG2);
    segmIMG2 = labelmatrix(CC);
    
    %% !!!!!!!!!!!!!!
    segmIMG=segmIMG2;
%     segmIMG=appxIMG;
%     segmIMG=markIMG;

    disp('Done!')
    close(h)

end
