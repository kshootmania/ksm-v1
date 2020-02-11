#include "ksmcore.h"

#include <string>
#include <cstdint>
#include "line_graph.hpp"

LineGraph *CreateLineGraph()
{
    return new LineGraph;
}

void DestroyLineGraph(LineGraph *pLineGraph)
{
    delete pLineGraph;
}

void InsertPointToLineGraph(LineGraph *pLineGraph, int measure, double v)
{
    pLineGraph->insert(static_cast<std::int64_t>(measure), v);
}

void LineGraphValueAt(const LineGraph *pLineGraph, int measure, double *pRet)
{
    *pRet = pLineGraph->valueAt(static_cast<std::int64_t>(measure));
}

bool LineGraphContains(const LineGraph *pLineGraph, int measure)
{
    return static_cast<bool>(pLineGraph->count(measure));
}
