
% ADJUST() - Automatic EEG artifact Detector
% with Joint Use of Spatial and Temporal features
%
% Usage:
%   >> [art, horiz, vert, blink, disc,...
%         soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
%         soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin]=ADJUST (EEG,out)
% Simplified to
% [art, info] = ADJUST (EEG) % KP 07/01/20
%
% Inputs:
%   EEG        - current dataset structure or structure array (has to be epoched)
%   out        - (string) report file name
%
% Outputs:
%   art        - List of artifacted ICs
% Info.        - Structure with the following fields  % KP 07/01/20
%   horiz      - List of HEM ICs
%   vert       - List of VEM ICs
%   blink      - List of EB ICs
%   disc       - List of GD ICs
%   soglia_DV  - SVD threshold
%   diff_var   - SVD feature values
%   soglia_K   - TK threshold
%   meanK      - TK feature values
%   soglia_SED - SED threshold
%   SED        - SED feature values
%   soglia_SAD - SAD threshold
%   SAD        - SAD feature values
%   soglia_GDSF- GDSF threshold
%   GDSF       - GDSF feature values
%   soglia_V   - MEV threshold
%   nuovaV     - MEV feature values
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ADJUST
% Automatic EEG artifact Detector based on the Joint Use of Spatial and Temporal features
%
% Developed 2007-2014
% Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% Last update: 02/05/2014 by Marco Buiatti
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reference paper:
% Mognon A, Jovicich J, Bruzzone L, Buiatti M,
% ADJUST: An Automatic EEG artifact Detector based on the Joint Use of Spatial and Temporal features.
% Psychophysiology 48 (2), 229-240 (2011).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2009-2014 Andrea Mognon (1) and Marco Buiatti (2),
% (1) Center for Mind/Brain Sciences, University of Trento, Italy
% (2) INSERM U992 - Cognitive Neuroimaging Unit, Gif sur Yvette, France
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% VERSIONS LOG
%
% 02/05/14: Modified text in Report.txt (MB).
%
% 30/03/14: Removed 'message to the user' (redundant). (MB)
%
% 22/03/14: kurtosis is replaced by kurt for compatibility if signal processing
%           toolbox is missing (MB).
%
% V2 (07 OCTOBER 2010) - by Andrea Mognon
% Added input 'nchannels' to compute_SAD and compute_SED_NOnorm;
% this is useful to differentiate the number of ICs (n) and the number of
% sensors (nchannels);
% bug reported by Guido Hesselman on October, 1 2010.

% KP Removed lines to write output file 07/01/20

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% function [art, horiz, vert, blink, disc,...
%         soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
%         soglia_GDSF, GDSF, soglia_V, nuovaV, soglia_D, maxdin]=ADJUST (EEG,out)
function [art, horiz, vert, blink, disc,...
    soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
    soglia_GDSF, med2_GDSF, GDSF, soglia_V, med2_V, nuovaV, soglia_D, maxdin]=ADJUST (EEG)


%% Settings

% ----------------------------------------------------
% |  Change experimental settings in this section    |
% ----------------------------------------------------

% ----------------------------------------------------
% |  Initial message to user:                        |
% ----------------------------------------------------
%
% disp(' ')
% disp('Detects Horizontal and Vertical eye movements,')
% disp('Blinks and Discontinuities in dataset:')
% disp([EEG.filename])
% disp(' ')

% ----------------------------------------------------
% |  Collect useful data from EEG structure          |
% ----------------------------------------------------

% Check the presence of ICA activations

if isempty(EEG.icaact)
    disp('EEG.icaact not present. Recomputed from data.');
    % if length(size(EEG.data))==3
        %         EEG.icaact = EEG.icaweights*EEG.icasphere*reshape(EEG.data, size(EEG.icawinv,1), num_epoch*size(EEG.data,2));
        %         EEG.icaact = reshape(EEG.icaact,size(EEG.icawinv,1),size(EEG.data,2), num_epoch);
        %EEG.icaact = reshape(EEG.icaweights*EEG.icasphere*reshape(EEG.data,[size(EEG.data,1)...
        %    size(EEG.data,2)*size(EEG.data,3)]),[size(EEG.icawinv,1) size(EEG.data,2), num_epoch]);
%    else
 %       EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
  %  end
          % Above Commented and replaced by below by KP 30/08/2021
  EEG.icaact = eeg_getica(EEG);
end

%number of ICs=size(EEG.icawinv,1);

%number of time points=size(EEG.data,2);

if length(size(EEG.data))==3
    
    num_epoch=size(EEG.data,3);
    EEG_epoched = EEG;
    
else
    
    % num_epoch=0; % commented KP 06/05/2021
    EEG_epoched = eeg_regepochs(EEG, 5) % addded KP 06/05/2021
    num_epoch=size(EEG_epoched.data,3); % addded KP 06/05/2021
    
end
EEG_epoched.icaact = eeg_getica(EEG_epoched);

% Topographies and time courses normalization
%
% disp(' ');
% disp('Normalizing topographies...')
% disp('Scaling time courses...')
topografie=EEG.icawinv'; %computes IC topographies

for i=1:size(EEG.icawinv,2) % number of ICs
    
    ScalingFactor=norm(topografie(i,:));
    
    topografie(i,:)=topografie(i,:)/ScalingFactor;
    
    if length(size(EEG.data))==3
        EEG.icaact(i,:,:)=ScalingFactor*EEG.icaact(i,:,:);
    else
        EEG.icaact(i,:)=ScalingFactor*EEG.icaact(i,:);
    end
    
end
%
% disp('Done.')
% disp(' ')

% Variables memorizing artifacted ICs indexes

blink=[];

horiz=[];

vert=[];

disc=[];

%% Check EEG channel position information
nopos_channels=[];
for el=1:length(EEG.chanlocs)
    if(any(isempty(EEG.chanlocs(1,el).X)&isempty(EEG.chanlocs(1,el).Y)&isempty(EEG.chanlocs(1,el).Z)&isempty(EEG.chanlocs(1,el).theta)&isempty(EEG.chanlocs(1,el).radius)))
        nopos_channels=[nopos_channels el];
    end;
end

if ~isempty(nopos_channels)
    warning(['Channels ' num2str(nopos_channels) ' have incomplete location information. They will NOT be used to compute ADJUST spatial features']);
    disp(' ');
end;

pos_channels=setdiff(1:length(EEG.chanlocs),nopos_channels);

%% Feature extraction

disp(' ')
disp('Features Extraction:')

%GDSF - General Discontinuity Spatial Feature

disp('GDSF - General Discontinuity Spatial Feature...')

GDSF = compute_GD_feat(topografie,EEG.chanlocs(1,pos_channels),size(EEG.icawinv,2));


%SED - Spatial Eye Difference

disp('SED - Spatial Eye Difference...')

[SED,medie_left,medie_right]=computeSED_NOnorm(topografie,EEG.chanlocs(1,pos_channels),size(EEG.icawinv,2));


%SAD - Spatial Average Difference

disp('SAD - Spatial Average Difference...')

[SAD,var_front,var_back,mean_front,mean_back]=computeSAD(topografie,EEG.chanlocs(1,pos_channels),size(EEG.icawinv,2));


%SVD - Spatial Variance Difference between front zone and back zone

diff_var=var_front-var_back;

%epoch dynamic range, variance and kurtosis

K=zeros(num_epoch,size(EEG_epoched.icawinv,2)); %kurtosis


Kloc=K;
Vmax=zeros(num_epoch,size(EEG.icawinv,2)); %variance %

disp('Computing variance and kurtosis of all epochs...')
for i=1:size(EEG.icawinv,2) % number of ICs
    
    for j=1:num_epoch
        %  Vmax(j,i)=var(EEG.icaact(i,:,j));      %Changed KP 04/05/2021
        Vmax(j,i)=var(EEG_epoched.icaact(i,:,j)); %Changed KP 04/05/2021
        %   Kloc(j,i)=kurtosis(EEG.icaact(i,:,j));
        
        % K(j,i)=kurt(EEG.icaact(i,:,j)); %Changed KP 04/05/2021
        K(j,i)=kurt(EEG_epoched.icaact(i,:,j)); %Changed KP 04/05/2021
    end
end

% check that kurt and kurtosis give the same values:
% [a,b]=max(abs(Kloc(:)-K(:)))

%TK - Temporal Kurtosis

disp('Temporal Kurtosis...')

meanK=zeros(1,size(EEG.icawinv,2));

for i=1:size(EEG.icawinv,2)
    if num_epoch>100
        meanK(1,i)=trim_and_mean(K(:,i));
    else meanK(1,i)=mean(K(:,i));
    end
    
end


%MEV - Maximum Epoch Variance

disp('Maximum epoch variance...')

maxvar=zeros(1,size(EEG.icawinv,2));
meanvar=zeros(1,size(EEG.icawinv,2));

for i=1:size(EEG.icawinv,2)
    if num_epoch>100
        maxvar(1,i)=trim_and_max(Vmax(:,i)');
        meanvar(1,i)=trim_and_mean(Vmax(:,i)');
    else
        maxvar(1,i)=max(Vmax(:,i));
        meanvar(1,i)=mean(Vmax(:,i));
    end
end

% MEV in reviewed formulation:

nuovaV=maxvar./meanvar;



%% Thresholds computation

disp('Computing EM thresholds...')

% soglia_K=EM(meanK);
%
% soglia_SED=EM(SED);
%
% soglia_SAD=EM(SAD);
%
% soglia_GDSF=EM(GDSF);
%
% soglia_V=EM(nuovaV);
[soglia_K,med1_K,med2_K]=EM(meanK);

[soglia_SED,med1_SED,med2_SED]=EM(SED);

[soglia_SAD,med1_SAD,med2_SAD]=EM(SAD);

[soglia_GDSF,med1_GDSF,med2_GDSF]=EM(GDSF);

[soglia_V,med1_V,med2_V]=EM(nuovaV);

%% Horizontal eye movements (HEM)

disp(' ');
disp('Artifact Identification:');
disp('Horizontal Eye Movements...')


horiz=intersect(intersect(find(SED>=soglia_SED),find(medie_left.*medie_right<0)),...
    (find(nuovaV>=soglia_V)));

hor_bool=1; %true if there are artifacted ICs

if isempty(horiz) %no IC found
    
    hor_bool=0;
    
    
end



%% Vertical eye movements (VEM)

disp('Vertical Eye Movements...')



vert=intersect(intersect(find(SAD>=soglia_SAD),find(medie_left.*medie_right>0)),...
    intersect(find(diff_var>0),find(nuovaV>=soglia_V)));



ver_bool=1; %true if there are artifacted ICs

if isempty(vert) %no artifact found
    
    ver_bool=0;
    
    
end




%% Eye Blink (EB)

disp('Eye Blinks...')

blink=intersect ( intersect( find(SAD>=soglia_SAD),find(medie_left.*medie_right>0) ) ,...
    intersect ( find(meanK>=soglia_K),find(diff_var>0) ));



bl_bool=1; %true if there are artifacted ICs

if isempty(blink) %no blink component
    
    bl_bool=0;
    
end



%% Generic Discontinuities (GD)

disp('Generic Discontinuities...')

disc=intersect(find(GDSF>=soglia_GDSF),find(nuovaV>=soglia_V));

dsc_bool=1; %true if there are discontinuities

if isempty(disc) %no discontinuities
    
    
    dsc_bool=0;
    
end

aic=unique([blink disc horiz vert]);




%% Displaying results
%compute output variable
art = nonzeros( union (union(blink,horiz) , union(vert,disc)) )'; %artifact ICs

% these three are old outputs which are no more necessary in latest ADJUST version.
soglia_D=0;
soglia_DV=0;
maxdin=zeros(1,size(EEG.icawinv,2));


% Summarize Info for Output % Added by KP 07/01/20
info = struct('horiz', horiz, 'vert', vert, 'blink', blink, 'disc', disc, 'soglia_DV',soglia_DV, 'diff_var', diff_var, 'soglia_K', soglia_K, 'meanK', meanK, ...
    'soglia_SED', soglia_SED, 'SED', SED, 'Soglia_SAD', soglia_SAD, 'SAD', SAD, 'soglia_GDSF', soglia_GDSF, 'GDSF', GDSF, 'soglia_V', soglia_V, 'nuovaV', nuovaV);

return

%% The following sections have been moved to interface_ADJ in order to manage
%% continuous data

%
% %% Saving artifacted ICs for further analysis
%
% nome=['List_' EEG.setname '.mat'];
%
% save (nome, 'blink', 'horiz', 'vert', 'disc');
%
% disp(' ')
% disp(['Artifact ICs list saved in ' nome]);
%
%
% %% IC show & remove
% % show all ICs; detected ICs are highlighted in red color. Based on
% % pop_selectcomps.
%
% art = nonzeros( union (union(blink,horiz) , union(vert,disc)) )'; %artifact ICs
%
% %     [EEG] = pop_selectcomps_ADJ( EEG, 1:size(EEG.icawinv,1), art, horiz, vert, blink, disc,...
% %         soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
% %         soglia_TDR, topog_DR, soglia_V, maxvar, soglia_D, maxdin );
%     [EEG] = pop_selectcomps_ADJ( EEG, 1:size(EEG.icawinv,1), art, horiz, vert, blink, disc,...
%         soglia_DV, diff_var, soglia_K, med2_K, meanK, soglia_SED, med2_SED, SED, soglia_SAD, med2_SAD, SAD, ...
%         soglia_GDSF, med2_GDSF, topog_DR, soglia_V, med2_V, maxvar, soglia_D, maxdin );

