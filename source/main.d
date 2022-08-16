/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * main
 *
 * Main executable for `moss`
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module main;

import std.experimental.logger;

import moss.client;
import moss.core.logger;
import moss.client.cli;

/**
 * Main routine.
 *
 * Params:
 *      args = Runtime arguments
 * Returns: 0 if successful
 */
int main(string[] args) @safe
{
    configureLogger();
    globalLogLevel = LogLevel.trace;

    return () @trusted { return MossCLI.construct(args).process(args); }();
}
