function [out1, out2, out3] = kuba_fun(x)
rng(10)
out1 = randn(10,1);
out2 = randn(10,1);
rng(10)
out3 = randn(10,1).*x;
disp(out1)
disp(out2)
disp(out3)
end