function [] = vsi(DWI_folder,T2_pre_folder,T2star_pre_folder,T2_post_folder,T2star_post_folder,anatomie_folder)
%   *********************************************
%   *       VSI-brain    Vessel Size Index      *
%   *                                           *
%   * DESCRIPTION: this code allows the         *
%   *   quantification of the vessel size index *
%   *   (VSI) as describred in Tropres (2001)   *
%   *   It is composed by thefollowing parts:   *
%   *      [0] - Define ACQUISITION PARAMETERS  *
%   *      [1] - load dicom sequences           *
%   *             - anatomy                     *
%   *             - T2* pre                     *
%   *             - T2  pre                     *
%   *             - T2* post                    *
%   *             - T2  post                    *
%   *      [2] - extract T2 and T2*maps         *
%   *      [3] - evaluate VSI maps              *
%   *      [4] - show VSI maps and anatomy      *
%   *      [5] - evaluate VSI histogram         *
%   *********************************************

%   ********************************************** 
%   *    Project : VSI brain                    *
%   *    Name    : VSI_Jan                       *
%   *    Author  : Marco Dominietto              *
%   *    Date    : 11 Oct 2011 (start)           *
%   *              -- --- ---- (end)             *
%   *    Revision:                               *
%   **********************************************

%%clear all;

%   **********************************************
%   [0] - Define ACQUISITION PARAMETERS
%   **********************************************

N_sl = 10;      % - number of acquired slices;
N_p = 5;        % - number of parameter evaluated with Paravision
N_fr = 50;     % - number of frames;

% T2_pre_folder = uigetdir ;
% T2_pre_folder = strcat(T2_pre_folder,'/');
% T2star_pre_folder = uigetdir;
% T2star_pre_folder = strcat(T2star_pre_folder,'/');
% DWI_folder = uigetdir;
% DWI_folder = strcat(DWI_folder,'/'); 
% T2_post_folder = uigetdir;
% T2_post_folder = strcat(T2_post_folder,'/');
% T2star_post_folder = uigetdir ;
% T2star_post_folder = strcat(T2star_post_folder, '/');
% anatomie = uigetdir ;
% anatomie = strcat(anatomie, '/');

% T2_pre_folder =     '/Users/enes_poyraz/Desktop/MasterArbeit/JKLavsi1824/JKlavsi1824_JKl_Alvarez_VSI_271824_VSI__E4_P2_2.16.756.5.5.100.4219346268.3438.1338989652.3741/';
% T2star_pre_folder = '/Users/enes_poyraz/Desktop/MasterArbeit/JKLavsi1824/JKlavsi1824_JKl_Alvarez_VSI_271824_VSI__E5_P2_2.16.756.5.5.100.4219378424.21905.1338996091.1183/';
% DWI_folder =        '/Users/enes_poyraz/Desktop/MasterArbeit/JKLavsi1824/JKlavsi1824_JKl_Alvarez_VSI_271824_VSI__E3_P2_2.16.756.5.5.100.4219346268.3438.1338989338.3530/';
% T2_post_folder =    '/Users/enes_poyraz/Desktop/MasterArbeit/JKLavsi1824/JKlavsi1824_JKl_Alvarez_VSI_271824_VSI__E6_P2_2.16.756.5.5.100.4219378424.21905.1338995936.396/';
% T2star_post_folder ='/Users/enes_poyraz/Desktop/MasterArbeit/JKLavsi1824/JKlavsi1824_JKl_Alvarez_VSI_271824_VSI__E7_P2_2.16.756.5.5.100.4219378424.21905.1338996017.984/';
% anatomie_folder =   '/Users/enes_poyraz/Desktop/MasterArbeit/JKLavsi1824/JKlavsi1824_JKl_Alvarez_VSI_271824_VSI__E4_P1_2.16.756.5.5.100.4219346268.3765.1338989474.6/';


T = 50;      % Threshold to remove nois outside of the brain

%  -  check point 01
if (N_fr ~= (N_sl*N_p))        %  ~= not equal
    fprintf ('--> ERROR:Number of frame does not match the number of slice and parameters evaluated ! ! ! \n');
else fprintf (' --> Check point 01: parameters OK \n')
end


%   **********************************************
%   *      [1] - load dicom sequences           *
%   *      [2] - extract T2 and T2*maps         *
%   **********************************************

DWI_list = dir([DWI_folder 'im*']);
T2_pre_list = dir([T2_pre_folder 'im*']);% - read in a stricture the file name in the folder
T2star_pre_list = dir([T2star_pre_folder 'im*']);
T2_post_list = dir([T2_post_folder 'im*']);
T2star_post_list = dir([T2star_post_folder 'im*']);
anatomie_list = dir([anatomie_folder 'im*']);

% - NB: name s thesame for each folder (T2, T2* pre
                        % and post)
                        
%  - Load ONLY the T2 (and T2*,...) maps
profile on
for i=1:N_sl
   g= 3+(i-1)*5;
   T2_pre_file_names = T2_pre_list(g).name;
   T2star_pre_file_names = T2star_pre_list(g).name;   
   DWI_file_names = DWI_list(1*(i-1)+10).name;
   T2_post_file_names = T2_post_list(g).name;
   T2star_post_file_names = T2star_post_list(g).name; 
   anatomie_file_names = anatomie_list(1 + 16*(i-1)).name;
   
   T2_pre_map_info = dicominfo([T2_pre_folder T2_pre_file_names]);
   T2star_pre_map_info = dicominfo([T2star_pre_folder T2star_pre_file_names]);
   DWI_map_info = dicominfo([DWI_folder DWI_file_names]);
   T2_post_map_info = dicominfo([T2_post_folder T2_post_file_names]);
   T2star_post_map_info = dicominfo([T2star_post_folder T2star_post_file_names]);
   
   
   T2_pre_map(:,:,i) = dicomread([T2_pre_folder T2_pre_file_names]);            % - Load T2_pre_map
   T2star_pre_map(:,:,i) = dicomread([T2star_pre_folder T2star_pre_file_names]);    % - Load T2star_pre_map
   DWI_map(:,:,i) = dicomread([DWI_folder DWI_file_names]);                  % - Load DWI_map
   T2_post_map(:,:,i) = dicomread([T2_post_folder T2_post_file_names]);          % - Load T2_pre_map
   T2star_post_map(:,:,i) = dicomread([T2star_post_folder T2star_post_file_names]);
   anatomie_map(:,:,i) = dicomread([anatomie_folder anatomie_file_names]);% - Load T2star_pre_map
end


%  -  check point 02
fprintf (' --> Check point 02: all maps loaded OK \n')

%   **********************************************
%   *      [3] - evaluate VSI maps              *
%   **********************************************
%  evaluate differences (DELTA) between post and pre

ROI_folder = 'ROISET/';
ROI_files = dir(ROI_folder);
% Exclude '.' and '..' files 
ROI_files = ROI_files(arrayfun(@(x) ~strcmp(x.name(1),'.'),ROI_files));
% number of files 
nfiles = length(ROI_files);

for i=1:nfiles
    filename = ROI_files(i,1).name;
    ROIs(i) = ReadImageJROI(strcat(ROI_folder,filename));
    figure
    imshow(imadjust(anatomie_map(:,:,5)));
    hold on
    plot(ROIs(i).mnCoordinates(:,1),ROIs(i).mnCoordinates(:,2));   
    axis([0 200 0 200])
end

hold off;




filename = 'roi.mat';
if exist(filename,'file')
    load(filename);
else
    for i=1:N_sl
    BW(:,:,i) = roipoly(imadjust(anatomie_map(:,:,i)));
    end
    savefile = 'roi.mat';
    save(savefile,'BW');    
end





T2_pre_map_double = double(T2_pre_map);
T2_post_map_double = double(T2_post_map);
DWI_map_double = double(DWI_map);
T2star_post_map_double = double(T2star_post_map);
T2star_pre_map_double = double(T2star_pre_map);

DWI_map_double = imresize(DWI_map_double,[200 200]);

for i=1:N_sl
sus = 2.26 * 10^-7;  % SI einheit .. umgerechnet von cgs via 4*pi * cgs-wert
B0 = 200 ; % Scannerabhängig ( einheit Mghz )
gamma = 1 ;
D=abs(double(1/double(T2_post_map_double)) - double(1/T2_pre_map_double));  % TODO neu berechnen
Dstar=abs(double(1/(T2star_post_map_double) - 1/(T2star_pre_map_double)));

VSI_map = abs(0.425 * (double(DWI_map_double/ (sus * B0 * gamma) )).^(1/2) .* (Dstar./D).^(3/2));
%VSI_map = (Dstar./D).^(3/2);   % ./ divided voxel by voxel
end
%save(ROI.dat,'BW');
% .^ POWER voxel by voxel
% remove values > T (noise out of the brain                                  
out_values = find (VSI_map > T);
%out_values2 = find (VSI_map < 7); 
%VSI_map(out_values2) = 0 ;
VSI_map(out_values) = 0;
C = zeros(200, 200, 1, 10);
for i=1:N_sl
blub = VSI_map(:,:,i);
blub(isnan(blub)) = 0;
blub(BW(:,:,i) < 1) = 0 ;
% blub(blub < 5 ) = 0 ;
%  -  check point 03
fprintf (' --> Check point 03: VSI map evaluated OK n\')

figure(1);
subplot(3,4,i);
hist(nonzeros(blub),0:5:50); colormap jet ;

%figure(2);
%subplot(3,4,i);
%subimage(imagesc(anatomie_map(:,:,i))); 

figure(3);
subplot(3,4,i);
C(:,:,1,i) = blub ;
imagesc(blub);
colormap jet ; 
colorbar;
hold off
end

figure(4);
montage(C,jet);

end