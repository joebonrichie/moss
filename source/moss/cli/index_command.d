/*
 * This file is part of moss.
 *
 * Copyright © 2020-2021 Serpent OS Developers
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

module moss.cli.index_command;

public import moss.core.cli;

import moss.core;

/**
 * Generate repository index for all encountered packages
 */
@CommandName("index")
@CommandHelp("Generate basic repository index")
public struct IndexCommand
{
    /** Extend BaseCommand to provide indexing capability */
    BaseCommand pt;
    alias pt this;

    /**
     * Main entry point into the IndexCommand
     */
    @CommandEntry() int run(ref string[] argv)
    {
        import std.stdio : writeln;

        writeln("TODO: Index packages");
        return ExitStatus.Failure;
    }
}
