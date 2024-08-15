%% phase 1.5: Orient lagged edges
load('g_copy_debug.mat');
n_var = 3;
n = 10;
g = g_copy;
g(n,find(g(n,:)~=0)) = 1;
g(find(g(:,n)~=0),n) = 0;
adjMatrix = g;
for i=1:n-1
    adj = find(adjMatrix(:,i)~=0);
    i_lag = (i - mod(i-1,n_var)) / n_var;
    for k=1:size(adj, 1)
        k_lag = (adj(k) - mod(adj(k)-1,n_var)) / n_var;
        if (k_lag > i_lag)
           g(i, adj(k))= 1;
           g(adj(k), i)= 0;
        end
        if (i_lag > k_lag)
           g(adj(k), i) = 1;
           g(i, adj(k)) = 0;
        end
    end
end
disp(g)

