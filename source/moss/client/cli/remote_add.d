/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * moss.client.cli.remote_add
 *
 * Add remotes to the system
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module moss.client.cli.remote_add;

public import moss.core.cli;

import moss.client.cli : initialiseClient;
import moss.core.errors;
import moss.client.cli.remote : SupportedProtocols;
import std.algorithm : filter;
import std.algorithm.searching : startsWith, endsWith;
import std.file : exists;
import std.format;
import std.stdio : writeln;
import std.sumtype;
import std.experimental.logger;
import moss.client.ui;
import std.stdint : uint64_t;
import std.stdio;

/**
 * Add a remote to the system
 */
@CommandName("add") @CommandAlias("ar") @CommandUsage("[name] [URI]") @CommandHelp(
        "Add a new remote .stone collection index to the system.",
        "\nSupports both file:/// and https:// transport protocols."
        ~ "\n\nExample URI: https://dev.serpentos.com/protosnek/x86_64/stone.index") struct RemoteAddCommand
{
    BaseCommand pt;
    alias pt this;

    /**
     * Dispatch the add command
     */
    @CommandEntry() int run(ref string[] argv) @safe
    {
        if (argv.length != 2)
        {
            writeln("add: Requires [name] and [URI] parameters");
            return 1;
        }

        auto cl = initialiseClient(pt);
        scope (exit)
        {
            cl.close();
        }
        auto name = argv[0];
        auto uri = argv[1];

        /* URI points to a stone.index file? */
        if (!uri.endsWith("stone.index"))
        {
            error("Doesn't like look a valid URI. Must point to a stone.index file");
            return 1;
        }

        /* URI starts with supported protocol? */
        auto match = SupportedProtocols.filter!((i) => uri.startsWith(i));
        if (match.empty)
        {
            error(format!"Doesn't like look a valid URI. Must start with one of the following protocols: %s"(
                    SupportedProtocols));
            return 1;
        }

        /* URI is reachable? */
        if (uri.startsWith("file://"))
        {
            auto fileURIpath = uri["file://".length .. $];
            if (!fileURIpath.exists)
            {
                error(format!"Doesn't like look a valid URI. Cannot find %s on disk."(fileURIpath));
                return 1;
            }
        }

        /* FIXME: use moss-fetcher to handle this */
        if (uri.startsWith("http://", "https://"))
        {
            auto reachable = () @trusted {
                import etc.c.curl;
                import std.string : toStringz;

                /* attempt to "ping" the url */
                auto curl = curl_easy_init();
                long status = 0;
                if (curl)
                {
                    curl_easy_setopt(curl, CurlOption.url, uri.toStringz);
                    curl_easy_setopt(curl, CurlOption.nobody, true);
                    curl_easy_setopt(curl, CurlOption.followlocation, true);
                    curl_easy_setopt(curl, CurlOption.connecttimeout, 10);
                    curl_easy_perform(curl);
                    curl_easy_getinfo(curl, CurlInfo.response_code, &status);
                    curl_easy_cleanup(curl);
                }
                return status;
            }();
            if (reachable >= 300 || reachable < 200)
            {
                error(format!"Refusing to add remote as the URI is unreachable, status code: %s"(
                        reachable));
                return 1;
            }
        }

        /* Only permit unique remotes */
        foreach (repo; cl.remotes.active)
        {
            if (name == repo.id)
            {
                error(format!"A remote %s already exists with this name. Choose a unique name."(
                        repo.id));
                return 1;
            }
            if (uri == repo.uri)
            {
                error(format!"The uri %s already exists from the remote %s."(repo.uri, repo.id));
                return 1;
            }
            if (priority == repo.priority)
            {
                error(format!"%s already exists with the priority of %s. Choose a unique priority number."(repo.id,
                        repo.priority));
                return 1;
            }
        }

        return cl.remotes.add(name, uri, description, priority).match!((Failure f) {
            errorf("%s", f.message);
            return 1;
        }, (_) { infof("Added remote %s", name); return 0; });
    }

    /* Optional user description for remote */
    @Option("desc", "description", "User description to help identify the remote")
    string description = "User added repository";
    /* Higher priority wins */
    @Option("p", "priority", "Priority to enable this remote with")
    uint64_t priority = 0;
}
