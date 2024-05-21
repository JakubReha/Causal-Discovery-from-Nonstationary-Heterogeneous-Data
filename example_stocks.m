% example stocks: nonstationary data
clear all,clc,close all
addpath(genpath(pwd))
rng(10)


% x1->x2->x3, and the causal module of x1, x2, and x3 are nonstationary,
% and the causal modules change independently
load stocks

arr = arr(end-1000:end, [1, 2, 3, 11, 14, 15, 16]);
disp(size(arr))

Data = arr;
T = size(arr, 1);

% custom modification
plots.gt = false;

%% set the parameters
alpha = 0.05; % signifcance level of independence test
maxFanIn = 2; % maximum number of conditional variables
if (T<=1000) % for small sample size, use GP to learn the kernel width in conditional independence tests
    cond_ind_test='indtest_new_t';
    IF_GP = 1; 
else
    if (T>1000 & T<2000) % for relatively large sample size, fix the kernel width
    cond_ind_test='indtest_new_t';
    IF_GP = 0;
    else % for very large sample size, fix the kernel width and use random fourier feature to approximate the kernel
        cond_ind_test='indtest_new_t_RFF';
        IF_GP = 0;
    end
end
pars.pairwise = false;
pars.bonferroni = false;
pars.if_GP1 = IF_GP; % for conditional independence test
pars.if_GP2 = 1;  % for direction determination with independent change principle & nonstationary driving force visualization
pars.width = 0; % kernel width on observational variables (except the time index). If it is 0, then use the default kernel width when IF_GP = 0
pars.widthT = 0.1; % the kernel width on the time index
c_indx = [1:T]'; % surrogate variable to capture the distribution shift; 
                 % here it is the time index, because the data is nonstationary
Type = 0; 
% If Type=0, run all phases of CD-NOD (including 
%   phase 1: learning causal skeleton, 
%   phase 2: identifying causal directions with generalization of invariance, 
%   phase 3: identifying directions with independent change principle, and 
%   phase 4: recovering the nonstationarity driving force )
% If Type = 1, perform phase 1 + phase 2 + phase 3 
% If Type = 2, perform phase 1 + phase 2
% If Type = 3, only perform phase 1

%% run CD-NOD
[g_skeleton, g_inv, gns, SP] = nonsta_cd_new(Data, cond_ind_test, c_indx, maxFanIn, alpha, Type, pars, plots);


%figure, subplot(211),plot(R0{6}(1:T),'b');
%title('x3')

%figure, subplot(211),plot(R0{1}(1:T),'b');
%title('x1')

%figure, subplot(211),plot(R0{2}(1:T),'b');
%title('x2')

