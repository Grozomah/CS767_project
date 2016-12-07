%% Segmentation Master File


cd('E:\010-work\Segmentation\GUI\GUI');
% cd('\\L1220-IMAC\Data_2\Jeraj\PCF');

addpath('\\L1220-IMAC\Data_2\Jeraj\PCF\Doc\QTBI scripts')
addpath('\\L1220-IMAC\Data_2\Jeraj\PCF\Doc\QTBI scripts\Articulated Registration')
addpath('\\L1220-IMAC\Data_2\Jeraj\PCF\QTSI\QTSI_Scripts')
addpath('\\L1220-IMAC\Data\_Scripts\Matlab')
addpath('E:\010-work\Segmentation\GUI\GUI')
addpath('E:\010-work\003-localGit\generalCodes')
addpath('E:\010-work\GANAR')


% patient='1001B';
% scan='B1';
% ct_in=am2mat(['E:\010-work\', patient, '\', scan, '\Processed\', patient, '_', scan, '_1ct.am']);
% ctIMG=permute(ct_in.data, [2,1,3]);
% pet_in=am2mat(['E:\010-work\', patient, '\', scan, '\Processed\', patient, '_', scan, '_1pet_recon1_SUV.am']);
% petIMG=permute(pet_in.data, [2,1,3]);
% phys_in=am2mat(['E:\010-work\', patient, '\', scan, '\Processed\', patient, '_', scan, '_physiciancontours.am']);
% physIMG=permute(phys_in.data, [2,1,3]);
% sliceN=225;
