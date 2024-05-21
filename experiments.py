import matlab.engine
import numpy as np
import matplotlib.pyplot as plt
import networkx as nx
import pickle
import os
#plt.rcParams['text.usetex'] = True

def save_plots(out, name, save_path):
    gns = np.asarray(out["gns"])
    driving_force = np.asarray(out["driving_force"])
    cmodule_id = np.nonzero(gns[-1,:]==1)[0]
    for i in range(len(cmodule_id)):
        Yg = np.asarray(out["Yg_save"])[i]
        Yl = np.asarray(out["Yl_save"])[i]
        eigValueg = np.asarray(out["eigValueg_save"])[i]
        eigValuel = np.asarray(out["eigValuel_save"])[i]
        x_id = cmodule_id[i]
        pa_id = np.nonzero(gns[0:-1,x_id]==1)[0]

        plt.figure(figsize=(10, 5))
        plt.grid()
        plt.plot(Yg[:,0],'b')
        plt.plot(Yg[:,1],'--', color="0.5")
        plt.plot(driving_force[x_id], 'red')
        plt.legend([r'First component of $\lambda_i$ (eigenvalue: ' + str(np.round(eigValueg[0].real[0], 6)) + ')',
                r'Second component of $\lambda_i$ (eigenvalue: ' + str(np.round(eigValueg[1].real[0], 6)) + ')',
                r'Ground Truth'])
        plt.title('Visualization of change in ' + str(pa_id) + ' --> ' + str(x_id) + ' (with Gaussian kernel)')
        plt.savefig(os.path.join(save_path, name + '_gaussian_' + str(x_id) + '.png'))

        plt.figure(figsize=(10, 5))
        plt.grid()
        plt.plot(Yl[:,0],'b')
        plt.plot(Yl[:,1],'--', color="0.5")
        plt.plot(driving_force[x_id], 'red')
        plt.legend([r'First component of $\lambda_i$ (eigenvalue: ' + str(np.round(eigValuel[0].real[0], 6)) + ')',
                r'Second component of $\lambda_i$ (eigenvalue: ' + str(np.round(eigValuel[1].real[0], 6)) + ')',
                r'Ground Truth'])
        
        plt.title(r'Visualization of change in ' + str(pa_id) + ' --> ' + str(x_id) + ' (with Linear kernel)')
        plt.savefig(os.path.join(save_path, name + '_linear_' + str(x_id) + '.png'))
        plt.close()

        plt.figure(figsize=(10, 5))
        plt.grid()
        plt.plot(np.abs(eigValueg.real),'.-')
        plt.title('Absolute value of eigenvalues Gaussian kernel')
        plt.savefig(os.path.join(save_path, name + "_" + str(x_id) +'_gaussian_eigenvalues.png'))
        plt.close()

        plt.figure(figsize=(10, 5))
        plt.grid()
        plt.plot(np.abs(eigValuel.real),'.-')
        plt.title('Absolute value of eigenvalues Linear kernel')
        plt.savefig(os.path.join(save_path, name + "_" + str(x_id) +'_linear_eigenvalues.png'))
        plt.close()

    plt.figure()
    graph = nx.DiGraph(gns)
    graph = nx.relabel_nodes(graph, {0:1, 1:2, 2:3, 3:4, 4:5, 5:6, gns.shape[0]-1: 'C'})
    nx.draw(graph, with_labels=True, font_weight='bold', node_color='lightblue')
    plt.title('Estimated final graph')
    plt.savefig(os.path.join(save_path, name + '_estimated_final_graph.png'))
    plt.close()

    plt.figure()
    graph = nx.DiGraph(np.asarray(out["g_inv"]))
    graph = nx.relabel_nodes(graph, {0:1, 1:2, 2:3, 3:4, 4:5, 5:6, gns.shape[0]-1: 'C'})
    nx.draw(graph, with_labels=True, font_weight='bold', node_color='lightblue')
    plt.title('Estimated graph')
    plt.savefig(os.path.join(save_path, name + '_estimated_graph.png'))
    plt.close()


def save_pickle(name, out, save_path):
    with open(os.path.join(save_path, name + '.pkl'), 'wb') as file:
        pickle.dump(out, file)

def load_pickle(name, save_path):
    with open(os.path.join(save_path, name + '.pkl'), 'rb') as file:
        return pickle.load(file)
    
def run_experiment(name, experiment, save_path):
    if not os.path.exists(os.path.join(save_path, name + ".pkl")):
        print("Running experiment: " + name)
        out = experiment(nargout=1)
        save_pickle(name, out, save_path)
    else:
        print("Loading experiment: " + name)
        out = load_pickle(name, save_path)
    save_plots(out, name, save_path)


if __name__ == '__main__':
    eng = matlab.engine.start_matlab()
    save_path = '/Users/jreha/PhD_UvA/Causal-Discovery-from-Nonstationary-Heterogeneous-Data/plots/'
    eng.addpath(eng.genpath('/Users/jreha/PhD_UvA/Causal-Discovery-from-Nonstationary-Heterogeneous-Data'))

    # stochastic trend
    name = "example2_stochastic_trend"
    run_experiment(name, eng.example2, save_path)


    # function_change
    name = "example3_function_change_sigma10"
    run_experiment(name, eng.example3, save_path) 
    
    # reapearing edge
    name = "example5_reapearing_edge"
    run_experiment(name, eng.example5, save_path)    
    
    # smoothly flipping edge
    name = "example6_smoothly_flipping_edge"
    run_experiment(name, eng.example6, save_path)

    eng.quit()
