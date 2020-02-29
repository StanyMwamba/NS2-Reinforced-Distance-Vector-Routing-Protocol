// -*-	Mode:C++; c-basic-offset:8; tab-width:8; indent-tabs-mode:t -*- 

/*
 * This program is a Reinforced Distance Vector Routing Protocol
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

#ifndef lint
static const char rcsid[] =
    "@(#) $Header: /cvsroot/nsnam/ns-2/rlrouting/rtProtoRL.cc,v 1.9 2005/08/25 18:58:12 Nitsh Exp $ (USC/ISI)";
#endif

#include "agent.h"
#include "rtProtoRL.h"

int hdr_RL::offset_;

static class rtRLHeaderClass : public PacketHeaderClass {
public:
	rtRLHeaderClass() : PacketHeaderClass("PacketHeader/rtProtoRL",
					      sizeof(hdr_RL)) {
		bind_offset(&hdr_RL::offset_);
	} 
} class_rtProtoRL_hdr;

static class rtProtoRLclass : public TclClass {
public:
	rtProtoRLclass() : TclClass("Agent/rtProto/RL") {}
	TclObject* create(int, const char*const*) {
		return (new rtProtoRL);
	}
} class_rtProtoRL;


int rtProtoRL::command(int argc, const char*const* argv)
{
	if (strcmp(argv[1], "send-update") == 0) {
		ns_addr_t dst;
		dst.addr_ = atoi(argv[2]);
		dst.port_ = atoi(argv[3]);
		u_int32_t mtvar = atoi(argv[4]);
		u_int32_t size  = atoi(argv[5]);
		sendpkt(dst, mtvar, size);
		return TCL_OK;
	}
	return Agent::command(argc, argv);
}

void rtProtoRL::sendpkt(ns_addr_t dst, u_int32_t mtvar, u_int32_t size)
{
	daddr() = dst.addr_;
	dport() = dst.port_;
	size_ = size;
	
	Packet* p = Agent::allocpkt();
	hdr_RL *rh = hdr_RL::access(p);
	rh->metricsVar() = mtvar;

	target_->recv(p);
}

void rtProtoRL::recv(Packet* p, Handler*)
{
	hdr_RL* rh = hdr_RL::access(p);
	hdr_ip* ih = hdr_ip::access(p);
	Tcl::instance().evalf("%s recv-update %d %d", name(),
			      ih->saddr(), rh->metricsVar());
	Packet::free(p);
}
