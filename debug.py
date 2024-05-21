import matlab.engine

eng = matlab.engine.start_matlab()
save_path = "/Users/jreha/PhD_UvA/projects/Causal-Discovery-from-Nonstationary-Heterogeneous-Data/plots/"
eng.addpath(
    eng.genpath(
        "/Users/jreha/PhD_UvA/projects/Causal-Discovery-from-Nonstationary-Heterogeneous-Data"
    )
)

print(eng.kuba_fun(matlab.double(0)))
