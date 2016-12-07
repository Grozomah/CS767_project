%% Final project master script

% "One Script to rule them all,
% one Script to find them,
% one Script to bring them all
% and in the Matlab bind them"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd ('E:\005-faks\CS767\CS767_project')
open('GUI.m')

addpath('E:\005-faks\CS767\CS767_project')
addpath('E:\005-faks\CS767\CS767_project\GCmex2.0')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Prep sample data
open('intelligentScissorSegm.m')
open('Sandbox_1111.m')

%% Get the analysis up and running
open('gc_example.m')