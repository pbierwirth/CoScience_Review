# CoScience_Review

This Repository contains all Preprocessing and Analytical functions used in in the CoScience Project

######################################################### 

***To Run the Test, open and run TEST_RDF.m (or any of the other TEST Files)***

#########################################################


In detail, the folders contain
* **Analysis_Functions** - contain all EEGLAB functions, including plugins, functions to export in BIDS format etc. and custom made functions to handle the forking

* **Step_Functions** - for the different analyses and preprocessing the corresponding step functions. Each step function lists all choices (and conditions for these choices). These functions are called in the parfor_Forks scripts. These are the scripts you should focus on when reviewing the analysis.

* **Parfor_Functions** - functions to run the forking (for one subject) in parallel, checking which path should be calculated.
                    They include 2 important functions: parfor_Forks and parfor_Forks_Other. The first one is for the primary analysis carried out
                    In order to save some time, the second function is used to run other analysis on the continous data. Eg. for the Alpha_Context analysis,
                    three tasks are preprocessed: Resting, Stroop, Gambling. Since the preprocessing is the same when data is kept continous, the other analyses 
                     (Stroop_LPP,  Gambling_RewP,...) are also calculated. 
                     The important function here is parfor_Forks.m - it handles when and which other functions should be called

All of these files above are compiled, depending on the analysis (e.g. for Alpha Context, the Step Functions for Preprocessing, Epoching Tasks, and Quantification Alpha are used together with the analysis functions). These compilations are then run on the server on parallel nodes to run multiple subjects in parallel. [This is not done for this test to better troubleshoot]


* **Only_ForGit_To_TestRun** - includes some files that are only included to test the Scripts. The test scripts are adjusted to mirror the behaviour of the job scheduler on the high performance cluster. If the scripts are run, the data will be calculated here. The folders are:
                        
    * **RawData**  - contains the eeg + behavioral data from three subjects from the resting and stroop task in the BIDS format
    
    * **ForkingFiles** - contains the files that inform about the forking combinations, contains the following for each analysis (Alpha_Context, Stroop_LPP)
        * *DESIGN.mat* - overview of all Steps, their order, choices, and conditions (e.g. look for bad IC components only when ICA was calculated). Also contains information if intermediate Step should be saved. [For now Data is only saved after Line Noise Filter and the later Low Pass Filter, and the final quantification] This information has been read out of the headers of the Step_Function Files, thats why they should not be changed
        * *FORKS.mat* - list of randomly drawn Forking combinations. For this test these are only 75 very different combinations. Ultimately these will be over 1000
                      and distributed across two to six files. The forks are listed in terms of theire choices (for each step), separated by %
        * *List_Subsets* - contains a Folder for each Task used in this analysis that lists which forks should still be run
              * *20 - Folder* of highest step number. To control parallelisation and file storage, the Parfor_Functions can be run only to a certain step, then another
                  step,  in order to delete interim saves from the previous step
                  For each subject, there is then a .csv file that lists which FORKS.mat files need to be run (in real analyses there are more than 1), or if no file
                  is listed, then the subject was completed before. These files will be created and updated before the parfor_Functions are run [not relevant for 
                  this test]
         * *StatFORKS.txt* - contains overview of some Forks of the statistical procedure, mentions which Groupfile should be taken, what the choice combination is (in numbers) and in  words
     * **Logs** - contains Folder for each Analysis Name and Task, and these contain the following folders
             * *CompletionStatus* - if all forks from FORK.mat have been completed, a file is created here (this is used to update the joblist before running the
                                   parfor_Functions)
             * *ErrorMessages* - if a Step through an error, a detail list of where the error occurred (Subject, Step, Choice) as well as the error message (in the
                                file) is saved as txt
             * *Statistics* - a Logfile from R running the stats  is saved as txt
                                                         
     * **Alpha_Context** - Folder for each Analysis, with the "task-" subfolders. These contain the intermediate and final Forking Steps of the 
                    Preprocessing. 
          **task-Resting /Stroop** ...
                   This will contain a lot of folders. The forks are coded by number (not name as it would exceed max file names). The folders then contain
                         * *.mat* for the Subject, including the preprocessed data, information on the lab and previous steps etc.
                         * *error.mat* if there was an error with this step, these files are used to terminate the processing of a fork with a similiar stephistory
                         * *running.mat* if step is going to be saved and is currently in progress, this interim file is created and deleted as soon as the file is   saved
            * **Group_Data** - contains one example file where all information from all single subjects of one fork are merged across all tasks
                  
    
    * **QuestionnaireData/Alpha_Context** contains 4 txt files where the relevant Personality Scores have been extracted, they differ if they are "filtered" (attention 
                        checks and RT cutoffs applied or not) and if "outliers were removed" (based on mahalanobis)
    
    * **BehaviouralData** - contains taks_StroopRating_beh.txt which lists the Ratings (Valence/Arousal) of the pictures for each subject 
      
     
         
                     
                      