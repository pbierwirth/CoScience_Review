function prep_mvpa_general_coscience(part)

%% This function preprocessed the EEG and behavioural data and sorts them into the following conditions:
% correct
% error

%% A trial starts at "window_start" ms before the response and ends at "window_end" ms after the response. So one trial
% takes "window_length" ms. That is "dppt" data points per trial (dppt). Since the window
% size may vary in future analyses, it is better to have a variable
% containing the dppt so it can be changed easily.
window_start = -500;
window_end = 800;
window_length = window_end - window_start;
dppt = window_length/2;

%% Also specify input and output location.
bdir = 'C:\Users\elisa\Desktop\Projekte\(2)other_projects\Coscience\MVPA\'; % Base directory
input_dir = [bdir 'beispieldaten_mvpa\task-Flanker\1.1_2.1_3.1_4.1_5.1_6.1_7.1_8.1_9.1_10.1_11.1_12.4_13.1/'];   %Folder containing the raw data
output_dir = [bdir '01_Preprocessing\PreprocessedData\flanker\'];      %Folder where the preprocessed data is to be stored Preprocessed Data

%% extrat participant code

participant_codes = get_participant_codes(bdir, input_dir);

part_code = participant_codes(part) %Informing in the command window about which participant is being processed. 

filename = [input_dir, char(part_code), '.mat'];
EEG_data = load(filename);

%% Create vector containing the response types

events = struct2table(EEG_data.Data.data.EEG.event);
events_response = events(strcmp(events.Event, 'Response'),:);

for i = 1:(height(events_response));
        if events_response.ACC(i) == 1
        events_response.responsetype(i) = 1;
        elseif events_response.ACC(i) == 0
        events_response.responsetype(i) = 2;
        else 
        events_response.responsetype(i) = 0;    
        end
end

%% Create EEG substructures from 3d EEGmatrix containing only trials from the respective responsetype (dp x channels x trials)

data_EEG = permute(EEG_data.Data.data.EEG.data, [2 1 3]);
EEG_correct = EEG_data.Data.data.EEG.data(:,:,events_response.responsetype == 1);
EEG_error = EEG_data.Data.data.EEG.data(:,:,events_response.responsetype == 2);


%% sanity check: are there any empty rows in the EEG substructures?
empty_rows_correct(1:length(EEG_correct(1,1,:)),:) = zeros;
for i = 1:length(EEG_correct(1,1,:))
    if EEG_correct(:,:,i) == 0
        empty_rows_correct(i) = 1;
    else empty_rows_correct(i) = 0;
    end
end

empty_rows_error(1:length(EEG_error(1,1,:)),:) = zeros;
for i = 1:length(EEG_error(1,1,:))
    if EEG_error(:,:,i) == 0
        empty_rows_error(i) = 1;
    else empty_rows_error(i) = 0;
    end
end

all_empty_correct = sum(empty_rows_correct);
all_empty_error = sum(empty_rows_error);

fprintf('Results of sanity check: \nThere is a total of %d case(s) in which EEG_correct is empty.\n Check for causes.', all_empty_correct);
fprintf('Results of sanity check: \nThere is a total of %d case(s) in which EEG_error is empty.\n Check for causes.', all_empty_error);


%!!! remove empty trials from EEG matrices only after checking their validty!!!

% EEG_correct(:,:, (find(empty_rows_correct == 1))) = [];
% EEG_error(:,:, (find(empty_rows_error == 1))) = [];

%% Prepare output file.

%Information.
info.ConditionLables = {'1 = correct'; '2 = error'};
% info.ChannelLabels = {'Fp1', 'Fp2', 'F7', 'F3', 'Fz', 'F4', 'F8', 'FC5', 'FC1', 'FCz', 'FC2', 'FC6', 'T7', 'C3', 'Cz','C4', 'T8', 'CP5', 'CP1', 'CP2', ...
%                       'CP6', 'P7', 'P3', 'Pz', 'P4', 'P8', 'O1', 'Oz', 'O2', 'PO9', 'PO10', 'AF7', 'AF3', 'AF4', 'AF8', 'F5', 'F1', 'F2', 'F6', 'C3', ...
%                       'FT7', 'FC3', 'FC4', 'FT8', 'C4', 'C5', 'C1', 'C2' 'C6', 'TP7', 'CP3', 'CPz', 'CP4', 'TP8', 'P5', 'P1', 'P2', 'P6', 'PO7', 'PO3', 'POz' 'PO4', 'PO8'};
chanlocs_table = struct2table(EEG_data.Data.data.EEG.chanlocs);
info.ChannelLabels = [chanlocs_table.labels]';
info.participant = part;
info.n_correct = length(EEG_correct(1,1,:)); 
info.n_error = length(EEG_error(1,1,:)); 
info.n_total = sum([length(EEG_correct(1,1,:)),length(EEG_error(1,1,:))]);
info.n_trial_dp = dppt;
info.pre_event_baseline = abs(window_start);

eeg_sorted_cond(1).data = EEG_correct;
eeg_sorted_cond(2).data = EEG_error;

%Output directory and file name.
out_file = [output_dir char(part_code) '.mat'];
channels = EEG_data.Data.data.EEG.chanlocs;
channel_outfile = [bdir '02_MVPA\locations\' 'channel_inf' '.mat'];

%Save the information on the data
save(out_file, 'info', 'eeg_sorted_cond');
save(channel_outfile, 'channels');








