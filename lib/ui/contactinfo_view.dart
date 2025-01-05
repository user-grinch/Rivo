import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revo/extentions/theme.dart';
import 'package:revo/ui/qr_view.dart';
import 'package:revo/utils/share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ContactInfoView extends StatefulWidget {
  final Contact contact;
  const ContactInfoView(this.contact, {super.key});

  @override
  State<ContactInfoView> createState() => _ContactInfoViewState();
}

class _ContactInfoViewState extends State<ContactInfoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: context.colorScheme.secondaryContainer,
              image: const DecorationImage(
                image: AssetImage('assets/contact_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 100,
                left: 16,
                right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfilePicture(context),
                const SizedBox(height: 16),
                Text(
                  '${widget.contact.name.first} ${widget.contact.name.last}',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Action buttons
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildActionIcon(
                        context: context,
                        icon: widget.contact.isStarred
                            ? Icons.star
                            : Icons.star_border,
                        label: 'Favourite',
                        onClick: () {
                          setState(() {
                            widget.contact.isStarred =
                                !widget.contact.isStarred;
                          });
                          FlutterContacts.updateContact(widget.contact);
                        }),
                    _buildActionIcon(
                        context: context,
                        icon: Icons.qr_code,
                        label: 'QR Code',
                        onClick: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRCodePopup(
                                  data: generateVCardString(widget.contact)),
                            ),
                          );
                        }),
                    _buildActionIcon(
                      context: context,
                      icon: Icons.share,
                      label: 'Share',
                      onClick: () {
                        Share.shareXFiles([
                          XFile.fromData(
                              utf8.encode(generateVCardString(widget.contact)),
                              mimeType: 'text/plain')
                        ], fileNameOverrides: [
                          'contact.vcf'
                        ]);
                      },
                    ),
                    _buildActionIcon(
                        context: context,
                        icon: Icons.edit,
                        label: 'Edit',
                        onClick: () async {
                          if (await FlutterContacts.requestPermission()) {
                            await FlutterContacts.openExternalEdit(
                                widget.contact.id);
                          } else {
                            print("Permission denied to access contacts");
                          }
                        }),
                  ],
                ),

                const SizedBox(height: 16),
                _buildContactInfoSection(context),
                const SizedBox(height: 16),
                _buildAdditionalDetailsSection(context),
                const SizedBox(height: 24),
                _buildFlatOption(context, Icons.history, 'Call History'),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display all phone numbers
        if (widget.contact.phones.isNotEmpty)
          ...widget.contact.phones
              .map((phone) => _buildPhoneWithActionIcons(context, phone)),
      ],
    );
  }

  Widget _buildPhoneWithActionIcons(BuildContext context, var phone) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16), // Padding between phone numbers
      child: Row(
        children: [
          // Phone number text
          Expanded(
            child: Text(
              phone.number,
              style: GoogleFonts.cabin(
                textStyle: context.textTheme.bodyLarge,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          // Action icons (Call, Message, Video)
          Wrap(
            spacing: 8,
            children: [
              _buildLargeActionIcon(context, Icons.phone, 'Call'),
              _buildLargeActionIcon(context, Icons.message, 'Message'),
              _buildLargeActionIcon(context, Icons.video_call, 'Video'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeActionIcon(
      BuildContext context, IconData icon, String label) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon,
          color: context.colorScheme.primary, size: 24), // Increased size
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    return Positioned(
      top: 150,
      child: CircleAvatar(
        radius: 120,
        backgroundImage: widget.contact.photoOrThumbnail != null
            ? MemoryImage(widget.contact.photoOrThumbnail!)
            : null,
        child: widget.contact.photoOrThumbnail == null
            ? Icon(
                Icons.person,
                size: 100,
                color: context.colorScheme.onPrimaryContainer,
              )
            : null,
      ),
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required IconData icon,
    required String label,
    Function()? onClick,
  }) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
              onPressed: onClick,
              icon: Icon(icon, color: context.colorScheme.primary, size: 25)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cabin(
            textStyle: context.textTheme.bodyLarge,
            color: context.colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFlatOption(BuildContext context, IconData icon, String label) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: context.colorScheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.cabin(
          textStyle: context.textTheme.bodyLarge,
          color: context.colorScheme.onSurface,
        ),
      ),
      onTap: () {},
    );
  }

  Widget _buildAdditionalDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.contact.notes.isNotEmpty)
          _buildDetail(context, 'Notes', widget.contact.notes.first.note),
        if (widget.contact.groups.isNotEmpty)
          _buildDetail(context, 'Groups', widget.contact.groups.first.name),
        if (widget.contact.events.isNotEmpty)
          _buildDetail(
              context, 'Birthday', widget.contact.events.first.customLabel),
      ],
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.cabin(
              textStyle: context.textTheme.bodyLarge,
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
