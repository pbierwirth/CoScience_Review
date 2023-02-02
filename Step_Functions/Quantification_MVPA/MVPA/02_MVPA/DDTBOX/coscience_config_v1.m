function coscience_config_v1
%__________________________________________________________________________
% DDTBOX script written by Stefan Bode 01/03/2013
%
% The toolbox was written with contributions from:
% Daniel Bennett, Jutta Stahl, Daniel Feuerriegel, Phillip Alday
%
% The author further acknowledges helpful conceptual input/work from: 
% Simon Lilburn, Philip L. Smith, Carsten Murawski, Carsten Bogler,
% John-Dylan Haynes
%__________________________________________________________________________
%
% This script is the configuration script for the DDTBOX. All
% study-specific information for decoding, regression and groupl-level
% analyses are specified here.
%
%__________________________________________________________________________
%
% Variable naming convention: STRUCTURE_NAME.example_variable

global SLIST;
global SBJTODO;
global CALL_MODE;


%% ABOUT THIS SCRIPT
%Normal classification


%% GENERAL STUDY PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

% Decide whether to save the SLIST structure and EEG data in a .mat file
savemode = 0; % 1 = Save the SLIST as a mat file; 0 = Don't save the SLIST

bdir = 'C:\Users\elisa\Desktop\Projekte\(2)other_projects\Coscience\MVPA\'; % Base directory
input_dir = [bdir '01_Preprocessing\PreprocessedData\go_nogo\']; % Directory in which the decoding results will be saved
output_dir = [bdir '02_MVPA\DECODING_RESULTS\level_1\go_nogo\']; % Directory in which the decoding results will be saved
output_dir_group = [bdir '02_MVPA\DECODING_RESULTS\level_2\go_nogo\']; % Directory in which the group level results will be saved

sbj_code = get_participant_codes(bdir, input_dir);

   


%% CREATE SLIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

SLIST = []; 
sn = SBJTODO;

   
    % subject parameters
    SLIST.number = sn;
    SLIST.sbj_code = sbj_code{sn};    
    SLIST.output_dir = output_dir;
    SLIST.output_dir_group = output_dir_group;
    SLIST.data_struct_name = 'eeg_sorted_cond';
    
    % channels    
    SLIST.nchannels = 64; % Number of channels in the dataset
    SLIST.channels = 'ChannelLabels'; 
    SLIST.channel_names_file = 'channel_inf.mat'; % Name of the .mat file containing channel information
    SLIST.channellocs = [bdir '02_MVPA\locations\']; % Directory of the .mat file containing channel information
    SLIST.eyes = [1, 59, 60]; % Channel indices of ocular electrodes
    SLIST.extra = [1, 59:63]; % Channel indices of electrodes to exclude from the classification analyses
    
    % sampling rate and baseline
    SLIST.sampling_rate = 500; % Sampling rate (Hz)
    SLIST.pointzero = 500; % Corresponds to time zero, for example stimulus onset (in ms, from the beginning of the epoch)
     
        
%% CREATE DCGs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

    % Label each condition
    % Example: SLIST.cond_labels{condition number} = 'Name of condition';
    SLIST.cond_labels{1} = 'go_correct';
    SLIST.cond_labels{2} = 'nogo_error';
%     for flanker task:
%     SLIST.cond_labels{1} = 'correct';
%     SLIST.cond_labels{2} = 'error';
        
    % Discrimination groups
    
    % Enter the condition numbers of the conditions to discriminate between
    % Example: SLIST.dcg{Discrimination group number} = [condition number 1, condition number 2];
    SLIST.dcg{1} = [1 2]; %Go Corrects vs nogo error 
      
    % Label each discrimination group
    % Example: SLIST.dcg_labels{Discrimination group number} = 'Name of discrimination group'
    SLIST.dcg_labels{1} = 'go_corrects vs nogo_errors ';
%    for flanker task:
%   SLIST.dcg_labels{1} = 'corrects vs errors ';
       
    %SLIST.ndcg = size(SLIST.dcg,2);
    SLIST.nclasses = size(SLIST.dcg{1},2);      
 
    %SLIST.ncond = size(SLIST.cond_labels,2);
    SLIST.nruns = 1;
    
    SLIST.data_open_name = [input_dir (sbj_code{sn}) '.mat'];
    SLIST.data_save_name = [input_dir (sbj_code{sn}) '_data.mat'];
    
%% SAVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

% Save the SLIST structure and eeg_sorted_cond to a .mat file
if savemode == 1
    
    % DF NOTE: I have changed the second argument from 'eeg_sorted_cond' to
    % SLIST.data_struct_name so that it will still save the EEG data file
    % if the user decides to use a different variable name than
    % 'eeg_sorted_cond'
    save(SLIST.data_save_name, SLIST.data_struct_name, 'SLIST');
    
end  

