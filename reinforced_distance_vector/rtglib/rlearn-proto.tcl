### By Stany Mwamba ###
# Reinforced Distance Vector Route Computation
#########################################################

 # This prgram is a Reinforced Distance Vector Routing Protocol
 # v 1.0 2019/10/19 16∶27∶29 Stany Mwamba $
 #-------------------------------------------------------------
 # In This protocol we apply Reinforcement Learning for
 # improving Distant Vector, our programme is also based on
 # Distant Vector Routing Protocol by
 # Copyright (C) 1997 by the University of Southern California
 #
 # This program is free software; you can redistribute it and/or
 # modify it under the terms of the GNU General Public License,
 # version 2, as published by the Free Software Foundation.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #  
 # You may copy and distribute such a system following the
 # terms of the GNU GPL for this module and the licenses of the
 # other code concerned, provided that you include the source code of
 # that other code when and as the GNU GPL requires distribution of
 # source code.
 #
 # Note that people who make modified versions of this module
 # are not obligated to grant this special exception for their
 # modified versions; it is their choice whether to do so.  The GNU
 # General Public License gives permission to release a modified
 # version without this exception; this exception also makes it
 # possible to release a modified version which carries forward this
 # exception.
 
 # $Header: /cvsroot/nsnam/ns-2/tcl/rtglib/rlearn-proto.tcl,v 1.0 2019/10/19 16∶27∶29 Stany Mwamba $


Agent/rtProto/RL set UNREACHABLE	[rtObject set unreach_]
Agent/rtProto/RL set mid_		  0

Agent/rtProto/RL proc init-all args {
    if { [llength $args] == 0 } {
	set nodeslist [[Simulator instance] all-nodes-list]
    } else {
	eval "set nodeslist $args"
    }
    Agent set-maxttl Agent/rtProto/RL INFINITY
    eval rtObject init-all $nodeslist
    foreach node $nodeslist {
	set proto($node) [[$node rtObject?] add-proto RL $node]
    }
    foreach node $nodeslist {
	foreach nbr [$node neighbors] {
	    set rtobj [$nbr rtObject?]
	    if { $rtobj != "" } {
		set rtproto [$rtobj rtProto? RL]
		if { $rtproto != "" } {
		    $proto($node) add-peer $nbr [$rtproto set agent_addr_] [$rtproto set agent_port_]
		}
	    }
	}
    }
}

Agent/rtProto/RL instproc init node {
    global rtglibRNG

    $self next $node
    $self instvar ns_ rtObject_ ifsUp_
    $self instvar preference_ rtpref_ nextHop_ nextHopPeer_ metric_ multiPath_

    set UNREACHABLE [$class set UNREACHABLE]
    foreach dest [$ns_ all-nodes-list] {
	set rtpref_($dest) $preference_
	set nextHop_($dest) ""
	set nextHopPeer_($dest) ""
	set metric_($dest)  $UNREACHABLE
    }
    set ifsUp_ ""
    set multiPath_ [[$rtObject_ set node_] set multiPath_]
    set updateTime [$rtglibRNG uniform 0.0 0.5]
    $ns_ at $updateTime "$self send-periodic-update"
}

Agent/rtProto/RL instproc add-peer {nbr agentAddr agentPort} {
    $self instvar peers_
    $self set peers_($nbr) [new rtPeer $agentAddr $agentPort $class]
}

Agent/rtProto/RL instproc send-periodic-update {} {
    global rtglibRNG

    $self instvar ns_
    $self send-updates 1	;# Anything but 0
    set updateTime [expr [$ns_ now] + \
	    ([$class set advertInterval] * [$rtglibRNG uniform 0.9 1.1])]
    $ns_ at $updateTime "$self send-periodic-update"
}

Agent/rtProto/RL instproc compute-routes {} {
    $self instvar ns_ ifs_ rtpref_ metric_ nextHop_ nextHopPeer_
    $self instvar peers_ rtsChanged_ multiPath_
	$self instvar V_ eps_
	#V_ is value function table

    set INFINITY [$class set INFINITY]
    set MAXPREF  [rtObject set maxpref_]
    set UNREACH	 [rtObject set unreach_]
    set rtsChanged_ 0
    foreach dst [$ns_ all-nodes-list] {
	set p [lindex $nextHopPeer_($dst) 0]
	if {$p != ""} {
	    set metric_($dst) [$p metric? $dst]
	    set rtpref_($dst) [$p preference? $dst]
	}

	set pf $MAXPREF
	set mt $INFINITY
	set nh(0) 0
	set idx 0
	set mynbr(0) 0
	foreach nbr [lsort -dictionary [array names peers_]] {
	    set pmt [$peers_($nbr) metric? $dst]
	    set ppf [$peers_($nbr) preference? $dst]

	    # if peer metric not valid	continue
	    # if peer pref higher		continue
	    # if peer pref lower		set to latest values
	    # else peer pref equal
	    #	if peer metric higher	continue
	    #	if peer metric lower	set to latest values
	    #	else peer metrics equal	append latest values

	    if { $pmt < 0 || $pmt >= $INFINITY || $ppf > $pf || $pmt > $mt } \
		    continue
	    #if { $ppf < $pf || $pmt < $mt } {
		#set pf $ppf
		#set mt $pmt
		#unset nh	;# because we must compute *new* next hops
	    #}


		#using of reinforcement value
		#getting state and choosing a better
		#V1 and V2 are states of two best neighbors
		set V1 V_($nbr)
		set idx [expr $idx+1]
		set idx1 [expr $idx-1]
		set mynbr($idx) $nbr
		set V2 V_($mynbr($idx1)))
		
		if { $V1 > $V2} {
		set pf $ppf
		set mt $pmt
		unset nh
		}


	    set nh($ifs_($nbr)) $peers_($nbr)
	}
	catch "unset nh(0)"
	if { $pf == $MAXPREF && $mt == $INFINITY } continue
	if { $pf > $rtpref_($dst) ||				\
		($metric_($dst) >= 0 && $mt > $metric_($dst)) }	\
		continue
	if {$mt >= $INFINITY} {
	    set mt $UNREACH
	}

	incr rtsChanged_
	if { $pf < $rtpref_($dst) || $mt < $metric_($dst) } {
	    set rtpref_($dst) $pf
	    set metric_($dst) $mt
	    set nextHop_($dst) ""
	    set nextHopPeer_($dst) ""
	    foreach n [array names nh] {
		lappend nextHop_($dst) $n
		lappend nextHopPeer_($dst) $nh($n)
		if !$multiPath_ break;
	    }
	    continue
	}
	
	set rtpref_($dst) $pf
	set metric_($dst) $mt
	set newNextHop ""
	set newNextHopPeer ""
	foreach rt $nextHop_($dst) {
	    if [info exists nh($rt)] {
		lappend newNextHop $rt
		lappend newNextHopPeer $nh($rt)
		unset nh($rt)
	    }
	}
	set nextHop_($dst) $newNextHop
	set nextHopPeer_($dst) $newNextHopPeer
	if { $multiPath_ || $nextHop_($dst) == "" } {
	    foreach rt [array names nh] {
		lappend nextHop_($dst) $rt
		lappend nextHopPeer_($dst) $nh($rt)
		if !$multiPath_ break
	    }
	}
    }
    set rtsChanged_
}

Agent/rtProto/RL instproc intf-changed {} {
    $self instvar ns_ peers_ ifs_ ifstat_ ifsUp_ nextHop_ nextHopPeer_ metric_
    $self instvar V_ eps_
	set INFINITY [$class set INFINITY]
    set ifsUp_ ""
    foreach nbr [lsort -dictionary [array names peers_]] {
	set state [$ifs_($nbr) up?]
	if {$state != $ifstat_($nbr)} {
	    set ifstat_($nbr) $state
	    if {$state != "up"} {
		if ![info exists all-nodes] {
		    set all-nodes [$ns_ all-nodes-list]
		}
		foreach dest ${all-nodes} {
		    $peers_($nbr) metric $dest $INFINITY
		}
		#updating value function when note is unavailable, reward is negative.
		#mettre à jour la value fonction etat negatif.
		V_($nbr) [expr -1+ 0.8*$V_($nbr)] 
	    } else {
		#updating value function when note is available
		#reward is positive 
		lappend ifsUp_ $nbr 
		V_($nbr) [expr 1+ 0.8*$V_($nbr)]
	    }
	}
    }
}

Agent/rtProto/RL proc get-next-mid {} {
    set ret [Agent/rtProto/RL set mid_]
    Agent/rtProto/RL set mid_ [expr $ret + 1]
    set ret
}

Agent/rtProto/RL proc retrieve-msg id {
    set ret [Agent/rtProto/RL set msg_($id)]
    Agent/rtProto/RL unset msg_($id)
    set ret
}

Agent/rtProto/RL instproc send-updates changes {
    $self instvar peers_ ifs_ ifsUp_

    if $changes {
	set to-send-to [lsort -dictionary [array names peers_]]
    } else {
	set to-send-to $ifsUp_
    }
    set ifsUp_ ""
    foreach nbr ${to-send-to} {
	if { [$ifs_($nbr) up?] == "up" } {
	    $self send-to-peer $nbr
	}
    }
}

Agent/rtProto/RL instproc send-to-peer nbr {
    $self instvar ns_ rtObject_ ifs_ peers_
    set INFINITY [$class set INFINITY]
    foreach dest [$ns_ all-nodes-list] {
	set metric [$rtObject_ metric? $dest]
	if {$metric < 0} {
	    set update($dest) $INFINITY
	} else {
	    set update($dest) [$rtObject_ metric? $dest]
	    foreach nh [$rtObject_ nextHop? $dest] {
		if {$nh == $ifs_($nbr)} {
		    set update($dest) $INFINITY
		}
	    }
	}
    }
	##this section is
    ### modifed by Liang Guo, 11/11/99, what if there's no peer on that end?
    ### needed when only part of the network nodes are using DV routing
    if { $peers_($nbr) == "" } {
        return
    }
    ##################### End ##########

    set id [$class get-next-mid]
    $class set msg_($id) [array get update]

    # XXX Note the singularity below...
    $self send-update [$peers_($nbr) addr?] [$peers_($nbr) port?] $id [array size update]
}

Agent/rtProto/RL instproc recv-update {peerAddr id} {
    $self instvar peers_ ifs_ nextHopPeer_ metric_
    $self instvar rtsChanged_ rtObject_

    set INFINITY [$class set INFINITY]
    set UNREACHABLE  [$class set UNREACHABLE]
    set msg [$class retrieve-msg $id]
    array set metrics $msg
    foreach nbr [lsort -dictionary [array names peers_]] {
	if {[$peers_($nbr) addr?] == $peerAddr} {
	    set peer $peers_($nbr)
	    if { [array size metrics] > [Node set nn_] } {
		error "$class::$proc update $peerAddr:$msg:$count is larger than the simulation topology"
	    }
	    set metricsChanged 0
	    foreach dest [array names metrics] {
                set metric [expr $metrics($dest) + [$ifs_($nbr) cost?]]
		if {$metric > $INFINITY} {
		    set metric $INFINITY
		}
		if {$metric != [$peer metric? $dest]} {
		    $peer metric $dest $metric
		    incr metricsChanged
		}
	    }
	    if $metricsChanged {
		$self compute-routes
		incr rtsChanged_ $metricsChanged
		$rtObject_ compute-routes
	    } else {
		# dynamicDM multicast hack.
		# If we get a message from a neighbour, then something
		# at that neighbour has changed.  While this may not
		# cause any unicast changes on our end, dynamicDM
		# looks at neighbour's routing tables to compute
		# parent-child relationships, and has to do them
		# again.
		#
		$rtObject_ flag-multicast -1
	    }
	    return
	}
    }
    error "$class::$proc update $peerAddr:$msg:$count from unknown peer"
}

Agent/rtProto/RL proc compute-all {} {
    # Because proc methods are not inherited from the parent class.
}
