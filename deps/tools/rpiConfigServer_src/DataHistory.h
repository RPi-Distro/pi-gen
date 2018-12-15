/*----------------------------------------------------------------------------*/
/* Copyright (c) 2018 FIRST. All Rights Reserved.                             */
/* Open Source Software - may be modified and shared by FRC teams. The code   */
/* must be accompanied by the FIRST BSD license file in the root directory of */
/* the project.                                                               */
/*----------------------------------------------------------------------------*/

#ifndef RPICONFIGSERVER_DATAHISTORY_H_
#define RPICONFIGSERVER_DATAHISTORY_H_

#include <stdint.h>

#include <algorithm>
#include <numeric>

template <typename T, size_t Size>
class DataHistory {
 public:
  void Add(T val) {
    if (m_qty >= Size) {
      std::copy(&m_data[1], &m_data[Size], &m_data[0]);
      m_data[Size - 1] = val;
    } else {
      m_data[m_qty++] = val;
    }
  }

  /* first is "least recent", last is "most recent" */
  bool GetFirstLast(T* first, T* last, size_t* qty) const {
    if (m_qty == 0) return false;
    if (first) *first = m_data[0];
    if (last) *last = m_data[m_qty - 1];
    if (qty) *qty = m_qty;
    return true;
  }

  /* only look at most recent "count" samples */
  bool GetFirstLast(T* first, T* last, size_t* qty, size_t count) const {
    if (count == 0 || m_qty < count) return false;
    if (first) *first = m_data[m_qty - count];
    if (last) *last = m_data[m_qty - 1];
    if (qty) *qty = m_qty;
    return true;
  }

  T GetTotal(size_t* qty = nullptr) const {
    if (qty) *qty = m_qty;
    return std::accumulate(&m_data[0], &m_data[m_qty], 0);
  }

 private:
  T m_data[Size];
  size_t m_qty = 0;
};

#endif  // RPICONFIGSERVER_DATAHISTORY_H_
