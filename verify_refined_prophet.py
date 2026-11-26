"""Exact check of a seven-edge upper bound for prophet matching. Python 3.

For these q,r and every integer m >= 2, rejecting all six early edges
earns 1 in expectation. After accepting the i-th edge as a first match,
the optimal continuation values for i = 1,...,6 are, in order,
1-q, q, q+(1-q)*r, r, 0, 0. The first follows by backward induction on
the three remaining edges at vertex 0, since the mean on (0,5) is 1-q.
Each positive first match plus its continuation is therefore worth 1.

Every early matching contains at most two edges of weight at most 1.
Whenever the final edge hits, the offline optimum equals m. Otherwise
its mean is H, computed below. Thus the ratio is 1/(1+(1-1/m)*H).
Letting m grow gives the limiting upper bound, and the finite example
tests the same conclusion to twelve decimal places.
"""

from fractions import Fraction as F
from functools import cache
from itertools import product
from math import prod


def instance(q, r, m):
    # Each tuple gives the endpoints, the positive weight and its probability.
    return (
        (1, 4, q, 1),
        (0, 3, 1 - q, 1),
        (0, 2, (1 - q) * (1 - r), 1),
        (0, 5, 1 - r, (1 - q) / (1 - r)),
        (1, 5, 1, q),
        (1, 3, 1, r),
        (0, 1, m, F(1, m)),
    )


def online(edges):
    @cache
    def value(i, used):
        if i == len(edges):
            return 0
        u, v, w, p = edges[i]
        skip = value(i + 1, used)
        endpoints = (1 << u) | (1 << v)
        if endpoints & used:
            return skip
        take = w + value(i + 1, used | endpoints)
        return p * max(skip, take) + (1 - p) * skip

    return value(0, 0)


def expected_offline(edges):
    matchings = []
    for chosen in product((0, 1), repeat=len(edges)):
        subset = [i for i, choose in enumerate(chosen) if choose]
        vertices = [v for i in subset for v in edges[i][:2]]
        if len(vertices) == len(set(vertices)):
            matchings.append(subset)
    mean = 0
    for hits in product((0, 1), repeat=len(edges)):
        probability = prod(e[3] if hit else 1 - e[3] for e, hit in zip(edges, hits))
        if probability:
            mean += probability * max(
                sum(edges[i][2] * hits[i] for i in subset) for subset in matchings
            )
    return mean


if __name__ == "__main__":
    q, r = F(603, 1330), F(163, 667)
    m = 10**14
    edges = instance(q, r, m)
    h = expected_offline(edges[:-1])
    # Rows are miss, hit for (0,5); columns are (0,0),(0,1),(1,0),(1,1)
    # for the indicators of (1,5) and (1,3), in that order.
    b = (1 - q) * (1 - r)
    conditional = ((1, 1 + b, 2 - q, 2 - q),
                   (1 + q - r, 2 - r, 2 - q, 2 - r))
    for i, j, k in product((0, 1), repeat=3):
        fixed = list(edges[:3]) + [
            (u, v, w * hit, 1)
            for (u, v, w, _), hit in zip(edges[3:6], (i, j, k))
        ]
        assert expected_offline(fixed) == conditional[i][2 * j + k]
    prophet = expected_offline(edges)
    alg = online(edges)
    finite = alg / prophet
    limit = 1 / (1 + h)
    assert alg == 1
    assert prophet == 1 + (1 - F(1, m)) * h
    assert limit < finite < F(414026190269, 10**12) < F(484, 1169)
    for label, value in (("ONLINE", alg), ("H", h), ("OFFLINE", prophet),
                         ("finite ratio", finite), ("limiting ratio", limit)):
        print(f"{label} = {value}")
