/* -*-	Mode:C++; c-basic-offset:8; tab-width:8; indent-tabs-mode:t -*- */

/*
 * This prgram is a Reinforced Distant Vector Routing Protocol
 * $Id: rtProtoDV.cc,v 1.0 2019/10/19 16∶27∶29 Stany Mwamba $
 *-------------------------------------------------------------
 * In This protocol we apply Reinforcement Learning for
 * improving Distant Vector, our programme is also based on
 * Distant Vector Routing Protocol by
 * Copyright (C) 1997 by the University of Southern California
 * $Id: DV.cc,v 1.9 2005/08/25 18:58:12 johnh Exp $
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *  
 * You may copy and distribute such a system following the
 * terms of the GNU GPL for this module and the licenses of the
 * other code concerned, provided that you include the source code of
 * that other code when and as the GNU GPL requires distribution of
 * source code.
 *
 * Note that people who make modified versions of this module
 * are not obligated to grant this special exception for their
 * modified versions; it is their choice whether to do so.  The GNU
 * General Public License gives permission to release a modified
 * version without this exception; this exception also makes it
 * possible to release a modified version which carries forward this
 * exception.
 *
 */

/* 
 * @(#) $Header: /cvsroot/nsnam/ns-2/rlrouting/rtProtoRL.h,v 1.0 2019/10/19 16∶27∶29 Stany Mwamba $
 */

#ifndef ns_rtprotorl_h
#define ns_rtprotorl_h

#include "packet.h"
#include "ip.h"

struct hdr_RL {
	u_int32_t mv_;			// metrics variable identifier

	static int offset_;
	inline static int& offset() { return offset_; }
	inline static hdr_RL* access(const Packet* p) {
		return (hdr_RL*) p->access(offset_);
	}

	// per field member functions
	u_int32_t& metricsVar() { return mv_; }
};

class rtProtoRL : public Agent {
public:
	rtProtoRL() : Agent(PT_RTPROTO_RL) {}//PT_RTPROTO_RL paquet pour RL
	int command(int argc, const char*const* argv);
	void sendpkt(ns_addr_t dst, u_int32_t z, u_int32_t mtvar);
	void recv(Packet* p, Handler*);
};

#endif
