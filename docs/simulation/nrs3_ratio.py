"""The Mandelstam–Tamm / Cramér–Rao ratio on the NRS³ path pair T_d : P_d (numpy).

T_d is the path adjacency over ρ_d = 2 cos(π/(d + 1)), P_d the centred position with unit
spacing 2/(d − 1) (nava-robertson-schrodinger, D3). ψ* is the top eigenvector of K = i[T_d, P_d]
(maximal tension). The ratio ⟨K⟩² / (4 Var T · Var P) at ψ* is 1/C_Nava(d)² (Lean, D41).
"""

import numpy as np

C_INF_SQ = np.pi ** 2 / 3 - 2


def ops(d):
    a = np.diag(np.ones(d - 1), 1)
    a = a + a.T
    rho = 2 * np.cos(np.pi / (d + 1))
    p = np.diag([(2 * (j + 1) - (d + 1)) / (d - 1) for j in range(d)])
    return a / rho, p


def ratio(d):
    t, p = ops(d)
    k = 1j * (t @ p - p @ t)
    w, v = np.linalg.eigh(k)
    z = v[:, -1]
    m = lambda x: (z.conj() @ x @ z).real
    vt, vp = m(t @ t) - m(t) ** 2, m(p @ p) - m(p) ** 2
    return m(k) ** 2 / (4 * vt * vp)
