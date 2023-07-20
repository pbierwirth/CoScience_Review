function  OUTPUT = Epoching(INPUT, Choice)
% Last Checked by KP 12/22
% Planned Reviewer:
% Reviewed by: 

% This script does the following:
% Depending onf the forking choice, resting data is epoched with different 
% window lengths and different overlaps.
% It is able to handle all options from "Choices" below (see Summary).


%#####################################################################
%### Usage Information                                         #######
%#####################################################################
% This function requires the following inputs:
% INPUT = structure, containing at least the fields "Data" (containing the
%       EEGlab structure, "StephHistory" (for every forking decision). More
%       fields can be added through other preprocessing steps.
% Choice = string, naming the choice run at this fork (included in "Choices")
%
% This function gives the following output:
% OUTPUT = struct, similiar to the INPUT structure. StepHistory and Data is
%           updated based on the new calculations. Additional fields can be
%           added below


%#####################################################################
%### Summary from the DESIGN structure                         #######
%#####################################################################
% Gives the name of the Step, all possible Choices, as well as any possible
% Conditional statements related to them ("NaN" when none applicable).
% SaveInterim marks if the results of this preprocessing step should be
% saved on the harddrive (in order to be loaded and forked from there).
% Order determines when it should be run.
StepName = "Epoching";
Choices = ["2_s_50_overlap", "1_s_50_overlap"];
Conditional = ["NaN", "NaN"];
SaveInterim = logical([0]);
Order = [12];



% ****** Updating the OUTPUT structure ******
% No changes should be made here.
INPUT.StepHistory.(StepName) = Choice;
OUTPUT = INPUT;
try % For Error Handling, all steps are positioned in a try loop to capture errors
    
    %#####################################################################
    %### Start Preprocessing Routine                               #######
    %#####################################################################
    
    Conditions = fieldnames(INPUT.data);
    for i_cond = 1:length(Conditions)
        % Get EEGlab EEG structure from the provided Input Structure
        EEG = INPUT.data.(Conditions{i_cond});
        
        % If Resting data was epoched before, concatenate the
        % non-overlapping epochs first.
        if strcmp(INPUT.StepHistory.Epoching_AC, "epoched")
            EEG = eeg_epoch2continuous(EEG);
            % Remove all "Boundaries", since there will be events for
            % start of epoch
            EEG.event(find(strcmp({EEG.event.type}, 'boundary'))) = [];
            % Remove X Triggers between consecutive epochs and include
            % 'boundary' between non-consecutive epochs
            IdxDelete = [];
            for ievent = 2:length(EEG.event)
                if strcmp(EEG.event(ievent).type,'X')
                    if EEG.event(ievent).urepoch == (EEG.event(ievent-1).urepoch+1)
                        IdxDelete = [IdxDelete, ievent];
                    else
                        EEG.event(ievent).type = 'boundary';
                    end
                end
            end
            EEG.event(IdxDelete) = [];
        end
        
        
        % ******  Epoch Resting Data according to input ******
        Parameters = strsplit(Choice, "_");
        windowlength = str2num(Parameters(1));
        repeat_trigg = (100-str2num(Parameters(3)))*windowlength/100;
        EEG = eeg_regepochs(EEG, repeat_trigg, [0 windowlength], 0, 'X', 'on');
        
        
        %#####################################################################
        %### Wrapping up Preprocessing Routine                         #######
        %#####################################################################
        % ****** Export ******
        % Script creates an OUTPUT structure. Assign here what should be saved
        % and made available for next step. Always save the EEG structure in
        % the OUTPUT.data field, overwriting previous EEG information.
        OUTPUT.data.(Conditions{i_cond}) = EEG;
    end
    
    
    % ****** Error Management ******
catch e
    % If error ocurrs, create ErrorMessage(concatenated for all nested
    % errors). This string is given to the OUTPUT struct.
    ErrorMessage = string(e.message);
    for ierrors = 1:length(e.stack)
        ErrorMessage = strcat(ErrorMessage, "//", num2str(e.stack(ierrors).name), ", Line: ",  num2str(e.stack(ierrors).line));
    end
    OUTPUT.Error = ErrorMessage;
end
end
