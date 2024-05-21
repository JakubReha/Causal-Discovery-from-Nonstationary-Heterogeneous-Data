function [out] = example6()
rng(0)
%% data generation
% generate data from the first domain
T_1 = 200;
x1_1 = randn(T_1,1);
x2_1 = 0.5*x1_1 + 0.5*randn(T_1,1);
x3_1 = linspace(0.5, 0, T_1)'.*x2_1 + 0.5*randn(T_1,1); 
x4_1 = 0.5*randn(T_1,1)+1; 
Data_1 = [x1_1,x2_1,x3_1,x4_1];

% generate data from the second domain
T_2 = 400;
x1_2 = randn(T_2,1);
x3_2 = 0.5*randn(T_2,1);
x2_2 = 0.5*x1_2 + 0.5*randn(T_2,1) + [linspace(0, 2, T_2/2), 2*ones(1, T_2/2)]'.*x3_2;
x4_2 = 0.5*randn(T_2,1)+1; 
Data_2 = [x1_2,x2_2,x3_2,x4_2];

% concateneate data from the two domains
Data = [Data_1;Data_2];


%% set the parameters
alpha = 0.05; % signifcance level of independence test
maxFanIn = 2; % maximum number of conditional variables
T  = size(Data,1);
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
pars.width = 0.4; % kernel width on observational variables (except the time index). If it is 0, then use the default kernel width when IF_GP = 0
pars.widthT = 0.1; % the kernel width on the time index; set it to zero for domain-varying data
c_indx = [ones(1,T_1),2*ones(1,T_2)]'; % surrogate variable to capture the distribution shift; 
                 %here it is the doamin index, because the data is from multiple domains
c_indx = [1:T_1 + T_2]';

% custom modification
plots.gt = true;
plots.plot = true;
plots.driving_force = zeros(4, T_1 + T_2);


plots.driving_force(3, :) = 5*[linspace(0.5, 0, T_1),zeros(1, T_2/2), zeros(1, T_2/2)];
plots.driving_force(2, :) = 5*[zeros(1, T_1),linspace(0, 2, T_2/2), 2*ones(1, T_2/2)];


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
[g_skeleton, g_inv, gns, SP, Yg_save,Yl_save,Mg_save,Ml_save,D_save,eigValueg_save,eigValuel_save] = nonsta_cd_new(Data, cond_ind_test, c_indx, maxFanIn, alpha, Type, pars, plots);


out.gns = gns;
out.g_inv = g_inv;
out.c_indx = c_indx;
out.Yg_save = Yg_save;
out.Yl_save = Yl_save;
out.Mg_save = Mg_save;
out.Ml_save = Ml_save;
out.D_save = D_save;
out.eigValueg_save = eigValueg_save;
out.eigValuel_save = eigValuel_save;
out.driving_force = plots.driving_force;
