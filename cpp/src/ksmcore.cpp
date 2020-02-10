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

double LineGraphValueAt(const LineGraph *pLineGraph, int measure)
{
    return pLineGraph->valueAt(static_cast<std::int64_t>(measure));
}
